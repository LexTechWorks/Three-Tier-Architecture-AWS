#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Buuh Bot — Discord</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" href="https://cdn-icons-png.flaticon.com/512/2111/2111370.png">
  <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-day: url('https://i.imgur.com/umW3UrJ.png');
      --bg-night: url('https://i.imgur.com/DM7oeRu.png');
    }
    html, body {
      margin: 0;
      padding: 0;
      font-family: 'Press Start 2P', cursive;
      color: white;
      background-image: var(--bg-night);
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      transition: background-image 0.5s ease;
      min-height: 100vh;
      overflow-x: hidden;
    }
    body.day {
      background-image: var(--bg-day);
    }
    .lanterna-dia {
      position: fixed;
      top: 0;
      left: 0;
      pointer-events: none;
      width: 100%;
      height: 100%;
      background-image: var(--bg-night);
      background-size: cover;
      background-position: center;
      -webkit-mask-image: radial-gradient(circle at var(--x, 50%) var(--y, 50%), rgba(255,255,255,1) 120px, transparent 300px);
      mask-image: radial-gradient(circle at var(--x, 50%) var(--y, 50%), rgba(255,255,255,1) 120px, transparent 300px);
      z-index: 5;
      opacity: 0.4;
    }
    nav {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      background-color: rgba(0, 0, 0, 0.7);
      padding: 10px;
      display: flex;
      justify-content: center;
      gap: 40px;
      z-index: 999;
    }
    nav a {
      color: #fff;
      text-decoration: none;
      font-size: 0.7em;
      transition: color 0.3s ease;
    }
    nav a:hover {
      color: #a64aff;
    }
    #commands-box, #support-box {
      position: absolute;
      top: 60px;
      background: rgba(0,0,0,0.85);
      padding: 14px;
      border-radius: 10px;
      font-size: 0.6em;
      width: 300px;
      display: none;
    }
    #commands-box {
      left: 10px;
      border: 2px solid #a64aff;
    }
    #support-box {
      right: 10px;
      border: 2px solid #55ddff;
    }
    .botao-discord {
      display: inline-block;
      margin: 20px auto;
      padding: 14px 40px;
      background-color: #7289da;
      border-radius: 30px;
      color: white;
      font-size: 1em;
      text-decoration: none;
      animation: entrada 1.5s ease, pulse 2s infinite;
      box-shadow: 0 0 12px rgba(255, 255, 255, 0.4);
      position: relative;
    }
    @keyframes pulse {
      0% { transform: scale(1); }
      50% { transform: scale(1.08); box-shadow: 0 0 25px rgba(255, 255, 255, 0.6); }
      100% { transform: scale(1); }
    }
    @keyframes entrada {
      from { opacity: 0; transform: translateY(-20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .theme-toggle {
      position: fixed;
      top: 80px;
      right: 20px;
      padding: 6px 10px;
      text-align: center;
      cursor: pointer;
      z-index: 999;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .theme-toggle img {
      width: 45px;
      height: 45px;
      border-radius: 50%;
      background-color: transparent;
      margin-bottom: 2px;
    }
    .theme-toggle span {
      font-size: 0.6em;
      background-color: rgba(0, 0, 0, 0.5);
      padding: 2px 6px;
      border-radius: 8px;
    }
  </style>
</head>
<body>
  <div class="lanterna-dia" id="lanterna"></div>

  <nav>
    <a href="#" onmouseover="document.getElementById('support-box').style.display='block'" onmouseout="document.getElementById('support-box').style.display='none'">Support</a>
    <a href="#" onmouseover="document.getElementById('commands-box').style.display='block'" onmouseout="document.getElementById('commands-box').style.display='none'">Commands</a>
  </nav>

  <div id="support-box">
    <h3>Precisa de ajuda?</h3>
    <p><strong>📌 Suporte via Discord:</strong></p>
    <a href="https://discord.gg/SEU_LINK_SUPORTE" target="_blank">Clique aqui</a>
    <p><strong>❓ Dúvidas comuns:</strong></p>
    <ul>
      <li>🔸 Bot não responde? Verifique permissões.</li>
      <li>🔸 Use !passaro para lucro interativo.</li>
      <li>🔸 Bot offline? Pode estar em manutenção.</li>
    </ul>
  </div>

  <div id="commands-box">
    <h3>Comandos do Buuh Bot</h3>
    <ul>
      <li><strong>!ping</strong> — Mostra a latência do bot.</li>
      <li><strong>!fabrica</strong> — Mostra receitas de fabricação.</li>
      <li><strong>!serverinfo</strong> — Info do servidor atual.</li>
      <li><strong>!userinfo</strong> — Info de um usuário.</li>
      <li><strong>!passaro</strong> — Calculadora de lucro.</li>
    </ul>
  </div>

  <header style="text-align: center; padding: 80px 20px 20px;">
    <img src="https://i.imgur.com/ue2bOSK.gif" alt="Fantasma" style="height: 50px; vertical-align: middle;">
    <h1 style="font-size: 1.8em; margin: 0; color: #ffffff; text-shadow: 2px 2px 4px #000000;">Buuh Bot</h1>
    <a href="https://discord.com/oauth2/authorize?client_id=1356649937970004251&scope=bot" class="botao-discord">
      <img src="https://media.tenor.com/WTbLkNWLriwAAAAi/couple-chase.gif" alt="add" style="height: 20px; vertical-align: middle; margin-right: 6px;">
      Add to Discord
    </a>
  </header>

  <div class="theme-toggle" onclick="toggleTheme()">
    <img id="theme-icon" src="https://media1.tenor.com/m/CE-lN924D-cAAAAd/brain-dump-max-g.gif" alt="Theme" />
    <span id="mode-label">Modo Noite</span>
  </div>

  <footer style="position: fixed; bottom: 10px; width: 100%; font-size: 0.6em; color: #ccc; text-align: center;">
    Buuh Bot © 2025 — Desenvolvido por JXVUM
    <img src="https://media1.tenor.com/m/AgPB0b_4FfUAAAAC/deadpixels-dpgc.gif" style="height: 24px; vertical-align: middle;">
  </footer>

  <script>
    const themeIcon = document.getElementById('theme-icon');
    const body = document.body;
    const label = document.getElementById('mode-label');
    const lanterna = document.getElementById('lanterna');
    let isDay = false;

    function toggleTheme() {
      isDay = !isDay;
      if (isDay) {
        body.classList.add('day');
        label.innerText = 'Modo Dia';
        themeIcon.src = 'https://media1.tenor.com/m/PilANcAf57UAAAAd/goofball-the-goofy-cartoon-ghost-max-g.gif';
        lanterna.style.backgroundImage = "var(--bg-night)";
        lanterna.style.display = 'block';
      } else {
        body.classList.remove('day');
        label.innerText = 'Modo Noite';
        themeIcon.src = 'https://media1.tenor.com/m/CE-lN924D-cAAAAd/brain-dump-max-g.gif';
        lanterna.style.backgroundImage = "var(--bg-day)";
        lanterna.style.display = 'block';
      }
    }

    document.addEventListener('mousemove', (e) => {
      lanterna.style.setProperty('--x', e.clientX + 'px');
      lanterna.style.setProperty('--y', e.clientY + 'px');
    });
  </script>
</body>
</html>
EOF