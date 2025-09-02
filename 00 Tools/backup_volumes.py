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
    volumes = get_docker_volumes()
    if not volumes:
        print("没有找到任何 Docker 卷.")
        return
    
    backup_dir = "./docker_volume_backup"
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

        if not volume.endswith('_data'):
            container_name = containers[0]
            new_name = f"{container_name}_data"
            # 修正 transform 规则以正确重命名目录及其内容
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

    if backed_up_count > 0:
        print(f"\n成功备份 {backed_up_count} 个卷至 {backup_path}")
    else:
        print("\n没有需要备份的正在使用的卷.")
        # 如果没有备份任何卷，删除可能已创建的 tar 文件
        if os.path.exists(backup_path):
            os.remove(backup_path)



def restore_volumes():
    """从备份文件恢复 Docker 卷"""
    backup_dir = "./docker_volume_backup"
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

def print_usage():
    """打印脚本使用说明"""
    print("用法: python backup_volumes.py [命令]")
    print("命令:")
    print("  list    - 列出所有 Docker 卷及其容器使用情况")
    print("  backup  - 备份所有 Docker 卷")
    print("  restore - 从备份文件恢复 Docker 卷")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)

    command = sys.argv[1]

    if command == "list":
        list_volumes_and_usage()
    elif command == "backup":
        backup_volumes()
    elif command == "restore":
        restore_volumes()
    else:
        print(f"未知命令: {command}")
        print_usage()
        sys.exit(1)
