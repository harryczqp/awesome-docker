import os
import subprocess
import datetime

def get_docker_volumes():
    """获取所有正在使用的 Docker 卷名称"""
    result = subprocess.run(["docker", "volume", "ls", "--format", "{{.Name}}"], capture_output=True, text=True)
    volumes = result.stdout.strip().split("\n")
    return [v for v in volumes if v]

def backup_volumes():
    """备份所有 Docker 卷并打包为 tar 文件"""
    volumes = get_docker_volumes()
    if not volumes:
        print("没有找到任何 Docker 卷.")
        return
    
    backup_dir = "./docker_volume_backup"
    os.makedirs(backup_dir, exist_ok=True)
    
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"docker_volumes_backup_{timestamp}.tar"
    backup_path = os.path.join(backup_dir, backup_file)
    
    print("开始备份 Docker 卷...")
    
    for volume in volumes:
        volume_path = f"/var/lib/docker/volumes/{volume}/_data"
        if os.path.exists(volume_path):
            tar_cmd = ["tar", "-rf", backup_path, "-C", volume_path, "."]
            subprocess.run(tar_cmd, check=True)
            print(f"已备份: {volume}")
        else:
            print(f"跳过: {volume} (路径不存在)")
    
    print(f"所有 Docker 卷已备份至 {backup_path}")

if __name__ == "__main__":
    backup_volumes()
