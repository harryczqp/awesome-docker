#1.让用户输入configs目录的路径，默认：/mnt/onedrive/configs/
#2.创建软链接到用户的etc目录下
#!/bin/bash
read -p "请输入configs目录的路径（默认：/mnt/onedrive/configs/）： " CONFIGS_PATH
CONFIGS_PATH=${CONFIGS_PATH:-/mnt/onedrive/configs/}
ETC_PATH="/etc"

if [ -d "$CONFIGS_PATH" ]; then
    ln -sfn "$CONFIGS_PATH" "$ETC_PATH/configs"
    echo "已创建软链接：$ETC_PATH/configs -> $CONFIGS_PATH"
else
    echo "错误：目录 $CONFIGS_PATH 不存在。请检查路径后重试。"
fi
