#!/usr/bin/env python3
"""Offline RustDesk -> BetterDesk v3.5.4, using the pinned upstream migrator."""
import argparse
import base64
from contextlib import closing
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import sqlite3
import subprocess
import tempfile
import urllib.request

VERSION = '3.5.4'
MIGRATOR_SHA256 = '186cc7d6766588da35732bd5b6ff56e59dbcd0681db352de71d6b92d19b3a5e0'
BASE = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def connect(path):
    return sqlite3.connect(path.as_uri() + '?mode=ro', uri=True)


def integrity(db):
    require(db.execute('PRAGMA integrity_check').fetchall() == [('ok',)],
            'SQLite integrity check failed')


def identities(db, legacy=False):
    table = 'peer' if legacy else 'peers'
    rows = db.execute(f'SELECT id, uuid, pk FROM {table} ORDER BY id').fetchall()
    result = {}
    for device_id, uuid, pk in rows:
        require(device_id not in result, 'Duplicate device ID; refusing lossy migration')
        require(bool(uuid) and isinstance(pk, bytes) and len(pk) == 32,
                'Missing/invalid device identity')
        if legacy:
            require(isinstance(uuid, bytes), 'Expected RustDesk UUID BLOB')
            uuid = uuid.hex()
        result[device_id] = (uuid, pk)
    require(bool(result), 'Empty device database; refusing migration')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=BASE / 'rustdesk')
    parser.add_argument('--output', type=Path, default=BASE / 'data')
    parser.add_argument('--migrator', type=Path, help='Optional previously downloaded official binary')
    parser.add_argument('--source-stopped', action='store_true',
                        help='Confirm source is an offline copy or hbbs/hbbr have stopped')
    args = parser.parse_args()
    require(args.source_stopped, 'Stop hbbs/hbbr or use an offline copy, then pass --source-stopped')
    require(platform.system() == 'Linux' and platform.machine() in ('x86_64', 'amd64'),
            'Upstream v3.5.4 migrator is Linux amd64 only; prepare data on Linux amd64')
    source, output = args.source.resolve(), args.output.absolute()
    require(not output.exists() and not output.is_symlink(), 'Output already exists; refusing overwrite')
    require(source != output and source not in output.parents, 'Output must be outside source')
    names = ['db_v2.sqlite3', 'id_ed25519', 'id_ed25519.pub']
    for name in names:
        require((source / name).is_file(), f'Missing source file: {name}')
    names += [n for n in ('db_v2.sqlite3-wal', 'db_v2.sqlite3-shm') if (source / n).exists()]
    before = {n: digest(source / n) for n in names}
    os.umask(0o077)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.betterdesk-migrate-', dir=output.parent) as temporary:
        stage = Path(temporary)
        backup = stage / 'source-backup'
        backup.mkdir()
        for name in names:
            shutil.copyfile(source / name, backup / name)
        require(before == {n: digest(backup / n) for n in names}, 'Source changed during copy')
        private = base64.b64decode((backup / 'id_ed25519').read_bytes().strip(), validate=True)
        public = base64.b64decode((backup / 'id_ed25519.pub').read_bytes().strip(), validate=True)
        require(len(private) == 64 and len(public) == 32 and private[32:] == public,
                'Invalid or mismatched RustDesk server key pair')
        # SQLite sees the copied WAL here. Never open the original database.
        working = stage / 'working'
        shutil.copytree(backup, working)
        snapshot = stage / 'snapshot.sqlite3'
        with closing(connect(working / 'db_v2.sqlite3')) as src, closing(sqlite3.connect(snapshot)) as dst:
            integrity(src)
            expected = identities(src, legacy=True)
            src.backup(dst)
        binary = stage / 'migrate'
        if args.migrator:
            shutil.copyfile(args.migrator, binary)
        else:
            url = f'https://github.com/UNITRONIX/BetterDesk/releases/download/v{VERSION}/migrate-linux-amd64'
            with urllib.request.urlopen(url, timeout=120) as response, binary.open('wb') as target:
                shutil.copyfileobj(response, target)
        require(digest(binary) == MIGRATOR_SHA256, 'Migrator checksum mismatch')
        binary.chmod(0o700)
        server = stage / 'server'
        server.mkdir()
        # Entrypoint drops DAC_OVERRIDE but can chown files inside searchable mounts.
        server.chmod(0o755)
        subprocess.run([str(binary), '-mode', 'rust2go', '-src', str(snapshot),
                        '-dst', str(server / 'db_v2.sqlite3')], check=True)
        with closing(connect(server / 'db_v2.sqlite3')) as migrated:
            integrity(migrated)
            require(expected == identities(migrated), 'ID / UUID / device public key mismatch')
        for name in ('id_ed25519', 'id_ed25519.pub'):
            shutil.copyfile(backup / name, server / name)
            require(digest(server / name) == before[name], 'Server key changed')
        require(before == {n: digest(source / n) for n in names}, 'Source changed; stop source and retry')
        result = stage / 'result'
        result.mkdir()
        server.rename(result / 'server')
        backup.rename(result / 'source-backup')
        (result / 'console').mkdir()
        (result / 'console').chmod(0o755)
        report = {'betterdesk_version': VERSION, 'devices_verified': len(expected),
                  'identity_fields': ['id', 'hex(uuid)', 'pk'], 'source_sha256': before,
                  'migrator_sha256': MIGRATOR_SHA256}
        (result / 'migration-report.json').write_text(json.dumps(report, indent=2) + '\n')
        (result / 'server' / '.migration-verified').write_text(f'{VERSION}: {len(expected)} devices\n')
        require(not output.exists(), 'Output appeared during migration; refusing overwrite')
        result.rename(output)
    print(f'Verified {len(expected)} device identities and unchanged server keys. Output: {output}')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, ValueError, sqlite3.Error, subprocess.CalledProcessError) as error:
        raise SystemExit(f'Migration aborted: {error}')
