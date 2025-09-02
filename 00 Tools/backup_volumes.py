import os
import sys
import subprocess
import datetime

def get_docker_volumes():
    """获取所有 Docker 卷名称"""
    result = subprocess.run(["docker", "volume", "ls", "--format", "{{.Name}}"], capture_output=True, text=True)
    volumes = result.stdout.strip().split("\n")
    return [v for v in volumes if v]

def get_containers_for_volume(volume_name):
    """获取使用特定 Docker 卷的容器列表"""
    cmd = ["docker", "ps", "-a", "--filter", f"volume={volume_name}", "--format", "{{.Names}}"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    containers = result.stdout.strip().split("\n")
    return [c for c in containers if c]

def list_volumes_and_usage():
    """列出所有 Docker 卷以及使用它们的容器"""
    volumes = get_docker_volumes()
    if not volumes:
        print("没有找到任何 Docker 卷.")
        return

    print("Docker 卷及其容器使用情况:")
    for volume in volumes:
        containers = get_containers_for_volume(volume)
        if containers:
            print(f"- {volume} (使用者: {', '.join(containers)})")
        else:
            print(f"- {volume} (未使用)")

def backup_volumes():
    """备份所有正在使用的 Docker 卷并打包为 tar 文件"""
    # 从环境变量获取备份目录，如果未设置则使用默认值
    backup_dir = os.getenv('DOCKER_BACKUP_DIR')
    if not backup_dir:
        backup_dir = "./docker_volume_backup"
        print(f"提示: 未设置 DOCKER_BACKUP_DIR 环境变量，将使用默认备份路径: {backup_dir}")

    # 检查是否启用停止容器功能
    stop_containers_enabled = os.getenv('STOP_CONTAINERS_FOR_BACKUP', 'false').lower() in ('true', '1', 'yes')
    if stop_containers_enabled:
        print("提示: 已启用(STOP_CONTAINERS_FOR_BACKUP 环境变量)备份前停止容器功能。")
    else:
        print("提示: 未启用(STOP_CONTAINERS_FOR_BACKUP 环境变量)备份前停止容器功能。")

    volumes = get_docker_volumes()
    if not volumes:
        print("没有找到任何 Docker 卷.")
        return
    
    os.makedirs(backup_dir, exist_ok=True)
    
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"docker_volumes_backup_{timestamp}.tar"
    backup_path = os.path.join(backup_dir, backup_file)
    
    print("开始备份正在使用的 Docker 卷...")
    
    volume_base_path = "/var/lib/docker/volumes"
    backed_up_count = 0
    for volume in volumes:
        containers = get_containers_for_volume(volume)
        if not containers:
            print(f"跳过: {volume} (未使用)")
            continue

        volume_path = os.path.join(volume_base_path, volume)
        if not os.path.exists(volume_path):
            print(f"跳过: {volume} (路径不存在)")
            continue

        containers_to_restart = []
        if stop_containers_enabled:
            for container in containers:
                try:
                    status_cmd = ["docker", "inspect", "-f", "{{.State.Status}}", container]
                    status_result = subprocess.run(status_cmd, check=True, capture_output=True, text=True)
                    if status_result.stdout.strip() == 'running':
                        print(f"  -> 正在停止容器 '{container}' 以安全备份卷 '{volume}'...")
                        stop_cmd = ["docker", "stop", container]
                        subprocess.run(stop_cmd, check=True, capture_output=True)
                        containers_to_restart.append(container)
                except subprocess.CalledProcessError as e:
                    print(f"  -> 警告: 无法检查或停止容器 '{container}': {e.stderr.strip()}")
        
        try:
            if not volume.endswith('_data'):
                container_name = containers[0]
                new_name = f"{container_name}_data"
                transform_rule = f"s,^{volume},{new_name},"
                tar_cmd = ["tar", "-rf", backup_path, "-C", volume_base_path, f"--transform={transform_rule}", volume]
                log_message = f"已备份: {volume} (在压缩包中重命名为 {new_name})"
            else:
                tar_cmd = ["tar", "-rf", backup_path, "-C", volume_base_path, volume]
                log_message = f"已备份: {volume}"

            try:
                subprocess.run(tar_cmd, check=True, capture_output=True)
                print(log_message)
                backed_up_count += 1
            except subprocess.CalledProcessError as e:
                print(f"备份 {volume} 时出错: {e.stderr.decode('utf-8', errors='ignore')}")
        
        finally:
            if containers_to_restart:
                print(f"  -> 正在重新启动为备份卷 '{volume}' 而停止的容器...")
                for container in containers_to_restart:
                    try:
                        start_cmd = ["docker", "start", container]
                        subprocess.run(start_cmd, check=True, capture_output=True)
                        print(f"     - 已启动: {container}")
                    except subprocess.CalledProcessError as e:
                        print(f"     - 警告: 无法重新启动容器 '{container}': {e.stderr.strip()}")

    if backed_up_count > 0:
        print(f"\n成功备份 {backed_up_count} 个卷至 {backup_path}")
    else:
        print("\n没有需要备份的正在使用的卷.")
        if os.path.exists(backup_path):
            os.remove(backup_path)


def restore_volumes():
    """从备份文件恢复 Docker 卷"""
    # 从环境变量获取备份目录，如果未设置则使用默认值
    backup_dir = os.getenv('DOCKER_BACKUP_DIR')
    if not backup_dir:
        backup_dir = "./docker_volume_backup"
        print(f"提示: 未设置 DOCKER_BACKUP_DIR 环境变量，正在从默认路径查找备份: {backup_dir}")

    if not os.path.exists(backup_dir):
        print(f"备份目录 '{backup_dir}' 不存在.")
        return

    backups = [f for f in os.listdir(backup_dir) if f.endswith(".tar")]
    if not backups:
        print(f"在 '{backup_dir}' 中没有找到备份文件.")
        return

    print("找到以下备份文件:")
    for i, backup in enumerate(backups):
        print(f"  {i + 1}: {backup}")

    try:
        choice = int(input("请选择要恢复的备份文件编号: ")) - 1
        if not 0 <= choice < len(backups):
            print("无效的选择.")
            return
    except ValueError:
        print("无效的输入.")
        return

    backup_to_restore = os.path.join(backup_dir, backups[choice])
    
    if os.geteuid() != 0:
        print("恢复操作需要 root 权限。请使用 'sudo' 运行此脚本.")
        return

    confirm = input(f"警告: 这将覆盖现有的同名卷。\n是否确定要从 '{backups[choice]}' 恢复? (y/n): ")
    if confirm.lower() != 'y':
        print("恢复操作已取消.")
        return

    restore_path = "/var/lib/docker/volumes/"
    print(f"正在从 {backup_to_restore} 恢复至 {restore_path}...")
    
    try:
        tar_cmd = ["tar", "-xf", backup_to_restore, "-C", restore_path]
        subprocess.run(tar_cmd, check=True)
        print("恢复完成.")
    except subprocess.CalledProcessError as e:
        print(f"恢复过程中发生错误: {e}")

def prune_unused_volumes():
    """清理所有未使用的 Docker 卷"""
    print("正在查找未使用的 Docker 卷...")
    volumes = get_docker_volumes()
    if not volumes:
        print("没有找到任何 Docker 卷.")
        return

    unused_volumes = []
    for volume in volumes:
        if not get_containers_for_volume(volume):
            unused_volumes.append(volume)

    if not unused_volumes:
        print("没有找到任何未使用的 Docker 卷.")
        return

    print("\n找到以下未使用的 Docker 卷:")
    for volume in unused_volumes:
        print(f"  - {volume}")

    try:
        confirm = input("\n警告: 此操作将永久删除以上列出的卷。\n是否继续? (请输入 'yes' 进行确认): ")
    except EOFError:
        print("\n非交互式环境中无法确认，操作已取消.")
        return

    if confirm.lower() != 'yes':
        print("操作已取消.")
        return

    print("\n开始清理未使用的卷...")
    deleted_count = 0
    for volume in unused_volumes:
        try:
            cmd = ["docker", "volume", "rm", volume]
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(f"已删除: {volume}")
            deleted_count += 1
        except subprocess.CalledProcessError as e:
            print(f"删除 {volume} 时出错: {e.stderr.strip()}")
    
    if deleted_count > 0:
        print(f"\n清理完成，共删除 {deleted_count} 个卷。")
    else:
        print("\n没有卷被删除.")

def print_usage():
    """打印脚本使用说明"""
    print("用法: python backup_volumes.py [命令]")
    print("命令:")
    print("  list    - 列出所有 Docker 卷及其容器使用情况")
    print("  backup  - 备份所有正在使用的 Docker 卷")
    print("  restore - 从备份文件恢复 Docker 卷")
    print("  prune   - 清理 (删除) 所有未使用的 Docker 卷")

def cleanup_old_backups():
    """根据环境变量配置的天数清理旧的备份文件"""
    try:
        retention_days_str = os.getenv('BACKUP_RETENTION_DAYS')
        if not retention_days_str:
            print("提示: 未设置 BACKUP_RETENTION_DAYS 环境变量，不执行清理操作。")
            return
        
        retention_days = int(retention_days_str)
        if retention_days <= 0:
            print("提示: BACKUP_RETENTION_DAYS 必须为正数，不执行清理。")
            return
            
    except (ValueError, TypeError):
        print(f"警告: 无效的 BACKUP_RETENTION_DAYS 设置 ('{retention_days_str}')，必须是一个有效的整数。")
        return

    backup_dir = os.getenv('DOCKER_BACKUP_DIR', './docker_volume_backup')

    if not os.path.isdir(backup_dir):
        print(f"提示: 备份目录 '{backup_dir}' 不存在，无需清理。")
        return

    print(f"开始清理 {retention_days} 天前的备份文件...")
    
    now = datetime.datetime.now()
    cutoff_date = now - datetime.timedelta(days=retention_days)
    cleaned_count = 0

    for filename in os.listdir(backup_dir):
        if filename.startswith("docker_volumes_backup_") and filename.endswith(".tar"):
            try:
                timestamp_str = filename.replace("docker_volumes_backup_", "").replace(".tar", "")
                file_date = datetime.datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")
                
                if file_date < cutoff_date:
                    file_path = os.path.join(backup_dir, filename)
                    os.remove(file_path)
                    print(f"已删除旧备份: {filename}")
                    cleaned_count += 1
            except ValueError:
                print(f"跳过: 无法从 '{filename}' 解析日期，文件名格式不正确。")
                continue
    
    if cleaned_count > 0:
        print(f"清理完成，共删除 {cleaned_count} 个旧备份。")
    else:
        print("没有找到需要清理的旧备份文件。")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)

    command = sys.argv[1]

    if command == "list":
        list_volumes_and_usage()
    elif command == "backup":
        backup_volumes()
        cleanup_old_backups()
    elif command == "restore":
        restore_volumes()
    elif command == "prune":
        prune_unused_volumes()
    else:
        print(f"未知命令: {command}")
        print_usage()
        sys.exit(1)
