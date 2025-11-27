```sh
touch acme.json
chmod 600 acme.json
htpasswd -cb .htpasswd your_admin_user your_secure_password
```

## http

```yaml
labels:
  - "traefik.enable=true"
  # 1. 定义路由规则
  - "traefik.http.routers.n8n-http.rule=Host(`n8n.yourdomain.com`)"
  # 2. 告诉 Traefik 使用 "web" (80) 入口
  - "traefik.http.routers.n8n-http.entrypoints=web"
  # 3. 告诉 Traefik 容器的端口
  - "traefik.http.services.n8n-service.loadbalancer.server.port=5678"
```



## https

```yaml
labels:
  - "traefik.enable=true"
  
  # --- HTTPS 路由 ---
  - "traefik.http.routers.gitea-https.rule=Host(`gitea.publicdomain.com`)"
  - "traefik.http.routers.gitea-https.entrypoints=websecure" # 1. 使用 443 入口
  - "traefik.http.routers.gitea-https.tls.certresolver=myresolver" # 2. 启用 SSL
  
  # --- (可选) 添加一个 HTTP 到 HTTPS 的重定向 (仅针对此服务) ---
  - "traefik.http.routers.gitea-http.rule=Host(`gitea.publicdomain.com`)"
  - "traefik.http.routers.gitea-http.entrypoints=web"
  - "traefik.http.routers.gitea-http.middlewares=redirect-to-https@docker"
  
  # 定义重定向中间件
  - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"

  # --- 服务端口定义 ---
  - "traefik.http.services.gitea-service.loadbalancer.server.port=3000"
```




sudo mkdir -p /var/log/traefik
sudo chmod 755 /var/log/traefik