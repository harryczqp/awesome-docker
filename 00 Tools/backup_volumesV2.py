import os
import datetime

def get_docker_volumes():
    """获取所有正在使用的 Docker 卷名称"""
    try:
        with open("/var/lib/docker/volumes/metadata.db", "r") as f:
            data = f.readlines()
        volumes = [line.split()[0] for line in data if line.strip()]
    except FileNotFoundError:
        print("无法获取 Docker 卷列表，文件不存在。")
        volumes = []
    return volumes

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
    
    with open(backup_path, "wb") as tar_file:
        for volume in volumes:
            volume_path = f"/var/lib/docker/volumes/{volume}/_data"
            if os.path.exists(volume_path):
                for root, _, files in os.walk(volume_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        with open(file_path, "rb") as f:
                            tar_file.write(f.read())
                print(f"已备份: {volume}")
            else:
                print(f"跳过: {volume} (路径不存在)")
    
    print(f"所有 Docker 卷已备份至 {backup_path}")

if __name__ == "__main__":
    backup_volumes()
