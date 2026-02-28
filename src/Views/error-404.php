<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" type="image/png" sizes="16x16" href="./assets/img/favicon.png">

  <?php header("HTTP/1.0 404 Not Found"); ?>

  <title>404 Not Found</title>
  <style>
    body {
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      background: linear-gradient(to right, #FFFF00, #FFD700, #FFA500, #FF8C00, #FF4500);
      color: #fff;
      text-align: center;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    }

    .error-container {
      max-width: 800px;
    }

    .error-code {
      font-size: 10rem;
      font-weight: bold;
    }

    .error-message {
      font-size: 1.5rem;
      width: 50%;
    }

    a {
      color: #fff;
      text-decoration: underline;
    }

    .cont {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 3rem;
      flex-wrap: wrap;
    }
  </style>
</head>

<body>
  <div class="error-container">
    <div class="cont">
      <div class="error-code">404</div>
      <div class="error-message">
        <h2>LO SIENTO!</h2>
        <p>No se ha encontrado la página que buscabas.</p>
      </div>
    </div>
    <a href="home" style="display: block; margin-top: 2rem">Ir al inicio</a>
    <p style="margin-top: 2rem;">Copyright &copy; 2025 Todos los derechos reservados.</p>
  </div>
</body>

</html>