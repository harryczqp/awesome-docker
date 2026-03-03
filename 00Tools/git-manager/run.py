import os
import csv
import subprocess
import sys
import argparse
import shutil

# --- 基础工具函数 ---

def run_git_cmd(cmd, cwd):
    """在指定目录执行 git 命令"""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            shell=True,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return True, result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return False, e.stderr.strip()

# --- 功能 1: 递归扫描并导出 (Recursive Scan) ---

def scan_repos(root_dir, output_csv):
    """递归扫描目录下所有层级的 Git 仓库信息"""
    if not os.path.isdir(root_dir):
        print(f"❌ 错误: 目录不存在 -> {root_dir}")
        return

    print(f"🔍 正在深度递归扫描: {root_dir} ...")
    print("⏳ 这可能需要一点时间，取决于文件数量...")
    
    repos_data = []
    
    # 使用 os.walk 进行深度遍历
    for current_root, dirs, files in os.walk(root_dir):
        # 如果当前目录下有 .git 文件夹，说明这是一个仓库根目录
        if ".git" in dirs:
            # 1. 计算相对路径 (例如: "Backend/Java/MyProject")
            # 这样恢复时就能保留目录结构
            relative_path = os.path.relpath(current_root, root_dir)
            
            # 2. 获取 Git 信息
            success, url = run_git_cmd("git remote get-url origin", current_root)
            if not success:
                url = "No-Remote"
            
            success, branch = run_git_cmd("git rev-parse --abbrev-ref HEAD", current_root)
            if not success:
                branch = "master"

            print(f"  ✅ 发现: {relative_path} | 分支: {branch}")
            repos_data.append([relative_path, url, branch])
            
            # 优化：找到 .git 后，通常不需要再往这个仓库内部深挖了（除非你有 submodule）
            # 从 dirs 中移除 .git，防止 os.walk 遍历进 .git 目录本身
            dirs.remove(".git")
            
        # 优化：忽略 node_modules, target 等常见垃圾目录，提高扫描速度
        # 如果你想扫描更彻底，可以注释掉下面这几行
        ignore_list = ["node_modules", "target", "dist", "venv", "__pycache__"]
        for ignore in ignore_list:
            if ignore in dirs:
                dirs.remove(ignore)

    # 写入 CSV
    try:
        with open(output_csv, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            # 修改表头: folder_name -> relative_path
            writer.writerow(["relative_path", "remote_url", "branch"]) 
            writer.writerows(repos_data)
        print(f"\n🎉 扫描完成！信息已保存至: {output_csv}")
        print(f"📊 共记录 {len(repos_data)} 个仓库。")
    except Exception as e:
        print(f"❌ 写入 CSV 失败: {e}")

# --- 功能 2: 基于路径恢复 (Restore) ---

def restore_repos(csv_path, target_root_dir):
    """从 CSV 读取信息并恢复 Git 仓库 (支持深层目录)"""
    if not os.path.exists(csv_path):
        print(f"❌ CSV 文件不存在: {csv_path}")
        return
    if not os.path.exists(target_root_dir):
        print(f"❌ 目标目录不存在: {target_root_dir}")
        return

    print(f"🚀 开始根据 {csv_path} 恢复仓库到 {target_root_dir} ...")

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            # 读取相对路径 (例如 Work/ProjectA)
            rel_path = row['relative_path']
            url = row['remote_url']
            branch = row['branch']
            
            if url == "No-Remote" or not url:
                continue

            # 拼接完整的物理路径
            project_path = os.path.join(target_root_dir, rel_path)

            # 检查文件夹是否存在
            if not os.path.exists(project_path):
                # 提示用户，因为这是恢复模式，理论上源码应该已经从 NAS 复制回来了
                print(f"⚠️  跳过: {rel_path} (目录不存在，请检查 NAS 文件是否已复制)")
                continue
            
            if os.path.exists(os.path.join(project_path, ".git")):
                print(f"⚪ 跳过: {rel_path} (.git 已存在)")
                continue

            print(f"🔄 正在恢复: {rel_path} ...")
            
            try:
                run_git_cmd("git init", project_path)
                
                success, msg = run_git_cmd(f"git remote add origin {url}", project_path)
                if not success:
                    print(f"   ❌ Remote Error: {msg}")
                    continue
                
                print(f"   ⬇️  Fetching...")
                success, msg = run_git_cmd("git fetch origin", project_path)
                if not success:
                    print(f"   ❌ Fetch Error: {msg}")
                    shutil.rmtree(os.path.join(project_path, ".git"), ignore_errors=True)
                    continue

                print(f"   🔗 Resetting to {branch}...")
                success, msg = run_git_cmd(f"git reset --mixed origin/{branch}", project_path)
                
                if success:
                    print(f"   ✅ 恢复成功！")
                else:
                    print(f"   ❌ Reset Error: {msg}")
                    
            except Exception as e:
                print(f"   ❌ Exception: {e}")

# --- 命令行入口 ---

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Git 仓库元数据备份与灾难恢复工具 (支持多级目录)")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Scan
    scan_parser = subparsers.add_parser("scan", help="递归扫描生成 CSV")
    scan_parser.add_argument("root_dir", help="项目根目录")
    scan_parser.add_argument("csv_file", help="保存 CSV 的路径")

    # Restore
    restore_parser = subparsers.add_parser("restore", help="从 CSV 恢复 Git 仓库")
    restore_parser.add_argument("csv_file", help="读取 CSV 的路径")
    restore_parser.add_argument("target_dir", help="目标根目录")

    args = parser.parse_args()

    if args.command == "scan":
        scan_repos(args.root_dir, args.csv_file)
    elif args.command == "restore":
        restore_repos(args.csv_file, args.target_dir)
    else:
        parser.print_help()