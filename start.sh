#!/bin/sh
echo "=== IPTV定时下载服务启动 ==="
echo "当前时间：$(date)"

# 定义优雅停止函数（收到停止信号时，杀死crond进程）
stop_service() {
  echo "=== 收到停止信号，正在关闭服务 ==="
  pkill crond  # 强制杀死crond进程
  exit 0
}

# 捕获容器停止信号（SIGTERM/SIGINT），触发优雅停止
trap stop_service SIGTERM SIGINT

# 校验必填参数
if [ -z "$TASK_URL" ] || [ -z "$FIXED_FILE_NAME" ] || [ -z "$TASK_CRON" ]; then
  echo "错误：请在docker-compose.yml中设置 TASK_URL、FIXED_FILE_NAME、TASK_CRON！"
  exit 1
fi

# 定义路径和变量
TASK_DIR=${TASK_DIR:-"/downloads"}
SAVE_PATH="$TASK_DIR/$FIXED_FILE_NAME"
OVERWRITE=${OVERWRITE:-"true"}
mkdir -p "$TASK_DIR"

# 打印任务配置
echo "=== 任务配置 ==="
echo "源文件链接：$TASK_URL（源文件名：$(basename $TASK_URL)）"
echo "目标文件名：$FIXED_FILE_NAME"
echo "保存路径（容器内）：$SAVE_PATH"
echo "定时规则：$TASK_CRON"
echo "是否覆盖旧文件：$OVERWRITE"

# 添加定时任务
CRON_CMD="$TASK_CRON curl -fSL \"$TASK_URL\" -o \"$SAVE_PATH\" || echo '[$(date)] 下载失败：$TASK_URL'"
(crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -

# 启动crond并前台运行（等待信号）
echo "=== 定时服务已启动，等待任务执行 ==="
crond -f &  # 后台运行crond，释放终端
wait $!     # 等待crond进程，同时监听停止信号
