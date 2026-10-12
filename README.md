# Bài 2: Đóng gói Web Backend bằng Single-stage Dockerfile

## Mục tiêu

Viết `Dockerfile` single-stage để đóng gói một REST API Node.js/Express thành Docker image `hw-backend:v1`, chạy container `app-single-stage` map cổng `8080:3000`.

## Cấu trúc thư mục

```
ex2/
├── Dockerfile
├── .dockerignore
├── package.json
├── server.js
└── README.md
```

## Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

ENV PORT=3000

COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
```

| Chỉ thị | Vai trò |
| --- | --- |
| `FROM node:18-alpine` | Base image Node.js 18 trên Alpine, dung lượng nhỏ |
| `WORKDIR /app` | Thư mục làm việc trong container |
| `ENV PORT=3000` | Cổng app lắng nghe, `server.js` đọc qua `process.env.PORT` |
| `COPY package.json` rồi `RUN npm install` | Copy file khai báo dependency trước để tận dụng layer cache: khi chỉ sửa `server.js`, Docker không cài lại thư viện |
| `COPY server.js` | Copy mã nguồn sau cùng |
| `EXPOSE 3000` | Khai báo cổng container (tài liệu hoá) |
| `CMD ["node", "server.js"]` | Exec form: `node` là PID 1, nhận tín hiệu `SIGTERM` đúng cách khi `docker stop` |

`.dockerignore` loại `node_modules`, `.git`... khỏi build context để build nhanh và image sạch.

## Cách chạy

```bash
docker build -t hw-backend:v1 .
docker run -d --name app-single-stage -p 8080:3000 hw-backend:v1
docker ps
docker logs app-single-stage
curl -i http://localhost:8080/
```

## Kết quả mong đợi

- Build hoàn tất không lỗi.
- `docker ps` hiển thị `app-single-stage` ở trạng thái `Up`.
- `docker logs app-single-stage`:

  ```
  Server listening on port 3000
  ```

- `curl -i http://localhost:8080/`:

  ```
  HTTP/1.1 200 OK
  Content-Type: application/json; charset=utf-8

  {"status":"success","message":"Hello from Docker Single-stage!"}
  ```

## Dọn dẹp

```bash
docker rm -f app-single-stage
docker rmi hw-backend:v1
```


{"status":"success","message":"Hello from Docker Single-stage!"}%               cachiu@Mac ex2 % curl -i http://localhost:8080/
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 64
ETag: W/"40-upZb7Fps+hszzRU9BoKtiCsmGCQ"
Date: Mon, 12 Oct 2026 01:58:26 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"status":"success","message":"Hello from Docker Single-stage!"}%               cachiu@Mac ex2 % 
