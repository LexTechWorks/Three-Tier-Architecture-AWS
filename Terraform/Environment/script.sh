#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <title>LexTechWorks</title>
  <style>
    body {
      background-color: #f4f4f4;
      font-family: Arial, sans-serif;
      text-align: center;
      padding-top: 100px;
    }
    h1 {
      font-size: 48px;
      color: #2c3e50;
    }
    p {
      font-size: 20px;
      color: #555;
      margin-top: 20px;
    }
  </style>
</head>
<body>
  <h1>LexTechWorks</h1>
  <p>Infraestrutura em nuvem inteligente, segura e escalável.</p>
</body>
</html>
EOF