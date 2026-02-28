<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>Starter Page - Restaurantly Bootstrap Template</title>
  <meta name="description" content="">
  <meta name="keywords" content="">

    <!-- Favicons -->
    <link rel="icon" type="image/png" sizes="16x16" href="./assets/img/favicon.png">

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com" rel="preconnect">
    <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900&display=swap" rel="stylesheet">

    <!-- Icons -->
    <link rel="stylesheet" href="https://unicons.iconscout.com/release/v4.0.8/css/line.css">

    <!-- Vendor CSS Files -->
    <link href="./assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="./assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
    <link href="./assets/vendor/aos/aos.css" rel="stylesheet">
    <link href="./assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
    <link href="./assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">

    <!-- Main CSS File -->
    <link href="./assets/css/web/main.css" rel="stylesheet">

    <!-- =======================================================
  * Template Name: Restaurantly
  * Template URL: https://bootstrapmade.com/restaurantly-restaurant-template/
  * Updated: Aug 07 2024 with Bootstrap v5.3.3
  * Author: BootstrapMade.com
  * License: https://bootstrapmade.com/license/
  ======================================================== -->
</head>

<body class="starter-page-page">

  <header id="header" class="header fixed-top">
    <div class="topbar d-flex align-items-center">
              <div class="container d-flex justify-content-center justify-content-md-between">
                  <div class="contact-info d-flex align-items-center">
                      <!-- <i class="bi bi-envelope d-flex align-items-center"><a href="mailto:contact@example.com">contact@example.com</a></i> -->
                      <a href="https://wa.me/+5804124921688" target="_blank">
                          <i class="bi bi-phone d-flex align-items-center ms-4"><span>+58 4124921688</span></i>
                      </a>
                  </div>
                  <div class="languages d-none d-md-flex align-items-center">
                      <ul>
                          <li>USD</li>
                          <li><a href="#">BS</a></li>
                      </ul>
                  </div>
              </div>
          </div><!-- End Top Bar -->

          <div class="branding d-flex align-items-cente">

              <div class="container position-relative d-flex align-items-center justify-content-between">
                  <a href="index.html" class="logo d-flex align-items-center me-auto me-xl-0">
                      <!-- Uncomment the line below if you also wish to use an image logo -->
                      <img src="./assets/img/favicon.png">
                      <h1 class="sitename">Burger House</h1>
                  </a>

                  <nav id="navmenu" class="navmenu">
                      <ul>
                          <li><a href="web#hero" class="active">Inicio <br></a></li>
                          <li><a href="web#about">Acerca de</a></li>
                          <li><a href="web#menu">Menú</a></li>
                          <li><a href="web#specials">Especiales</a></li>
                          <li><a href="web#events">Eventos</a></li>
                          <li><a href="web#chefs">Personal</a></li>
                          <li><a href="web#gallery">Galería</a></li>
                          <li><a href="web#book-a-table">Reservar</a></li>
                          <!-- <li class="dropdown"><a href="#"><span>Dropdown</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                <ul>
                  <li><a href="#">Dropdown 1</a></li>
                  <li class="dropdown"><a href="#"><span>Deep Dropdown</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                    <ul>
                      <li><a href="#">Deep Dropdown 1</a></li>
                      <li><a href="#">Deep Dropdown 2</a></li>
                      <li><a href="#">Deep Dropdown 3</a></li>
                      <li><a href="#">Deep Dropdown 4</a></li>
                      <li><a href="#">Deep Dropdown 5</a></li>
                    </ul>
                  </li>
                  <li><a href="#">Dropdown 2</a></li>
                  <li><a href="#">Dropdown 3</a></li>
                  <li><a href="#">Dropdown 4</a></li>
                </ul>
              </li> -->
                          <li><a href="#contact">Contacto</a></li>
                      </ul>
                      <i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
                  </nav>
                  <!-- cart -->
                  <a class="btn-book-a-table toolTip" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasRight" aria-controls="offcanvasRight" data-bs-toggle="tooltip" data-bs-placement="top" title="Carrito de compras"><i class="uil uil-shopping-cart-alt"></i></a>
                  <div class="offcanvas offcanvas-end bg-light" tabindex="-1" id="offcanvasRight" aria-labelledby="offcanvasRightLabel">
                      <div class="offcanvas-header">
                          <h5 id="offcanvasRightLabel" class="text-black">Carrito de compras</h5>
                          <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
                      </div>
                      <div class="offcanvas-body">
                          <?php if (!empty($_SESSION['cart'])): ?>
                              <?php $total = 0; ?>
                              <?php foreach ($_SESSION['cart'] as $position => $item): ?>
                                  <div class="d-flex align-items-center mb-3 border-bottom pb-3">
                                      <div class="flex-grow-1">
                                          <h5 class="mb-1 text-black"><?= htmlspecialchars($item['name']) ?></h5>
                                          <p class="mb-1 text-muted">Precio: $<?= htmlspecialchars($item['price']) ?></p>
                                          <p class="mb-1 text-muted">Cantidad: <?= htmlspecialchars($item['quantity']) ?></p>

                                          <!-- Mostrar detalles del pedido -->
                                          <?php if (!empty($item['details'])): ?>
                                              <p class="mb-1 text-muted"><strong>Detalles:</strong> <?= htmlspecialchars($item['details']) ?></p>
                                          <?php endif; ?>

                                          <!-- Mostrar adicionales -->
                                          <?php if (!empty($item['extras'])): ?>
                                              <p class="mb-0 text-muted"><strong>Adicionales:</strong> <?= htmlspecialchars(implode(', ', $item['extras'])) ?></p>
                                          <?php endif; ?>
                                      </div>
                                      <form method="post" action="?c=CCart/handleRequest" class="ms-3">
                                          <input type="hidden" name="action" value="remove">
                                          <input type="hidden" name="position" value="<?= $position ?>">
                                          <button type="submit" class="btn btn-book-a-table text-black btn-sm">Eliminar</button>
                                      </form>
                                  </div>
                                  <?php $total += $item['price'] * $item['quantity']; ?>
                              <?php endforeach; ?>
                              <div class="border-top pt-3 mt-3">
                                  <h5 class="text-end text-black">Subtotal: $<?= number_format(num: $total, decimals: 2) ?></h5>
                                  <h5 class="text-end text-black">Total (IVA incluido): $<span><?= number_format(num: $total * 1.16, decimals: 2) ?></span></h5>
                              </div>
                              <button type="button" class="btn btn-principal w-100 mt-3" data-bs-toggle="modal" data-bs-target="#addDrinksModal">Proceder al pago</button>
                              <!-- Botón para vaciar el carrito -->
                              <div class="d-flex justify-content-between align-items-center mt-3">
                                  <form method="post" action="?c=CCart/handleRequest">
                                      <input type="hidden" name="action" value="clear">
                                      <button type="submit" class="btn btn-danger w-100">Vaciar Carrito</button>
                                  </form>
                              </div>
                              <!-- Modal para agregar bebidas -->
                              <div class="modal fade" id="addDrinksModal" tabindex="-1" aria-labelledby="addDrinksModalLabel" aria-hidden="true" data-bs-backdrop="false">
                                  <div class="modal-dialog">
                                      <div class="modal-content bg-light">
                                          <form id="addDrinksForm" method="post" action="?c=CCart/handleRequest">
                                              <div class="modal-header">
                                                  <h5 class="modal-title text-black" id="addDrinksModalLabel">Agregar Bebidas</h5>
                                                  <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                              </div>
                                              <div class="modal-body">
                                                  <h6 class="text-black">Selecciona las bebidas que deseas agregar:</h6>
                                                  <div class="mb-3">
                                                      <div class="form-check d-flex align-items-center">
                                                          <input class="form-check-input me-2 drink-checkbox" type="checkbox" name="drinks[]" value="Coca Cola" id="drinkCocaCola" data-price="3">
                                                          <label class="form-check-label text-black me-3" for="drinkCocaCola">Coca Cola <span>($3)</span></label>
                                                          <input type="hidden" name="drinkPrice[Coca Cola]" value="3">
                                                          <input type="number" class="form-control w-25 drink-quantity" name="drinkQuantity[Coca Cola]" min="1" placeholder="Cantidad" disabled>
                                                      </div>
                                                      <div class="form-check d-flex align-items-center">
                                                          <input class="form-check-input me-2 drink-checkbox" type="checkbox" name="drinks[]" value="Sprite" id="drinkSprite" data-price="3">
                                                          <label class="form-check-label text-black me-3" for="drinkSprite">Sprite <span>($3)</span></label>
                                                          <input type="hidden" name="drinkPrice[Sprite]" value="3">
                                                          <input type="number" class="form-control w-25 drink-quantity" name="drinkQuantity[Sprite]" min="1" placeholder="Cantidad" disabled>
                                                      </div>
                                                      <div class="form-check d-flex align-items-center">
                                                          <input class="form-check-input me-2 drink-checkbox" type="checkbox" name="drinks[]" value="Agua mineral" id="drinkAgua mineral" data-price="3">
                                                          <label class="form-check-label text-black me-3" for="drinkAgua mineral">Agua mineral <span>($3)</span></label>
                                                          <input type="hidden" name="drinkPrice[Agua mineral]" value="3">
                                                          <input type="number" class="form-control w-25 drink-quantity" name="drinkQuantity[Agua mineral]" min="1" placeholder="Cantidad" disabled>
                                                      </div>
                                                      <div class="form-check d-flex align-items-center">
                                                          <input class="form-check-input me-2 drink-checkbox" type="checkbox" name="drinks[]" value="Jugo natural" id="drinkJugo natural" data-price="3">
                                                          <label class="form-check-label text-black me-3" for="drinkJugo natural">Jugo natural <span>($3)</span></label>
                                                          <input type="hidden" name="drinkPrice[Jugo natural]" value="3">
                                                          <input type="number" class="form-control w-25 drink-quantity" name="drinkQuantity[Jugo natural]" min="1" placeholder="Cantidad" disabled>
                                                      </div>
                                                  </div>
                                                  <div class="mt-3">
                                                      <h6 class="text-black">Total (Carrito + Bebidas, IVA incluido): $<span id="drinksTotal">0.00</span></h6>
                                                  </div>
                                              </div>
                                              <div class="modal-footer">
                                                  <button type="button" class="btn btn-book-a-table text-black" data-bs-dismiss="modal">Cerrar</button>
                                                  <button type="submit" class="btn btn-principal">Agregar al carrito</button>
                                              </div>
                                          </form>
                                      </div>
                                  </div>
                              </div>

                              <script>
                                  document.querySelectorAll('.drink-checkbox').forEach(function(checkbox) {
                                      checkbox.addEventListener('change', function() {
                                          const quantityInput = this.closest('.form-check').querySelector('.drink-quantity');
                                          if (this.checked) {
                                              quantityInput.disabled = false;
                                          } else {
                                              quantityInput.disabled = true;
                                              quantityInput.value = '';
                                          }
                                          calculateDrinksTotal();
                                      });
                                  });

                                  document.querySelectorAll('.drink-quantity').forEach(function(input) {
                                      input.addEventListener('input', calculateDrinksTotal);
                                  });

                                  function calculateDrinksTotal() {
                                      let drinksTotal = 0;

                                      // Calcular el total de las bebidas seleccionadas
                                      document.querySelectorAll('.drink-checkbox:checked').forEach(function(checkbox) {
                                          const price = parseFloat(checkbox.getAttribute('data-price'));
                                          const quantity = parseInt(checkbox.closest('.form-check').querySelector('.drink-quantity').value) || 0;
                                          drinksTotal += price * quantity;
                                      });

                                      // Obtener el total actual del carrito desde el DOM
                                      const cartTotalElement = document.querySelector('.offcanvas-body h5.text-end.text-black:last-child span');
                                      const cartTotal = cartTotalElement ? parseFloat(cartTotalElement.textContent.replace('$', '').replace(',', '')) || 0 : 0;

                                      // Calcular el total con IVA incluido
                                      const totalWithTax = cartTotal + drinksTotal;
                                      document.getElementById('drinksTotal').textContent = (totalWithTax).toFixed(2);
                                  }
                              </script>

                              <!-- Modal de Pago -->
                              <div class="modal fade" id="checkoutModal" tabindex="-1" aria-labelledby="checkoutModalLabel" aria-hidden="true" data-bs-backdrop="false">
                                  <div class="modal-dialog">
                                      <div class="modal-content bg-light">
                                          <div class="modal-header">
                                              <h5 class="modal-title text-black" id="checkoutModalLabel">Confirmar Pago</h5>
                                              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                          </div>
                                          <div class="modal-body">
                                              <h6 class="text-black">Productos seleccionados:</h6>
                                              <ul>
                                                  <?php foreach ($_SESSION['cart'] as $item): ?>
                                                      <li class="text-black"><?= htmlspecialchars($item['name']) ?> - $<?= htmlspecialchars($item['price']) ?> x <?= htmlspecialchars($item['quantity']) ?></li>
                                                  <?php endforeach; ?>
                                              </ul>
                                              <h6 class="text-black mt-3 text-end">Total a pagar: $<?= number_format($total * 1.16, 2) ?></h6>
                                              <form method="post" action="?c=CCart/handleRequest" enctype="multipart/form-data">
                                                  <div class="mb-3">
                                                      <label for="paymentMethod" class="form-label text-black">Método de Pago</label>
                                                      <select class="form-select" id="paymentMethod" name="payment_method" required>
                                                          <option value="pagomovil">Pago Móvil</option>
                                                          <option value="efectivo">Efectivo</option>
                                                          <option value="binance">Binance</option>
                                                          <option value="zelle">Zelle</option>
                                                      </select>
                                                  </div>
                                                  <div class="mb-3">
                                                      <label for="paymentReference" class="form-label text-black">Referencia</label>
                                                      <input type="text" class="form-control" id="paymentReference" name="payment_reference" placeholder="Número de referencia" required>
                                                  </div>
                                                  <div class="mb-3">
                                                      <label for="paymentImage" class="form-label text-black">Imagen del Pago</label>
                                                      <input type="file" class="form-control" id="paymentImage" name="payment_image" accept="image/*" required>
                                                  </div>
                                                  <div class="modal-footer">
                                                      <button type="button" class="btn btn-book-a-table text-black" data-bs-dismiss="modal">Cancelar</button>
                                                      <button type="submit" class="btn btn-principal">Confirmar Pago</button>
                                                  </div>
                                              </form>
                                          </div>
                                      </div>
                                  </div>
                              </div>
                          <?php else: ?>
                              <p class="text-center text-muted">Tu carrito está vacío.</p>
                          <?php endif; ?>
                      </div>
                  </div>
                  <!-- <a class="btn-book-a-table d-none d-md-block d-flex justify-content-center" href="#">Carrito<i class="uil uil-shopping-cart-alt"></i></a> -->
                  <a class="btn-book-a-table d-none d-xl-block" href="#">Iniciar Sesión</a>

              </div>

          </div>
  </header>

  <main class="main">

    <!-- Page Title -->
    <div class="page-title position-relative" data-aos="fade" style="background-image: url(assets/img/page-title-bg.webp);">
      <div class="container position-relative">
        <h1>Starter Page <br></h1>
        <p>Esse dolorum voluptatum ullam est sint nemo et est ipsa porro placeat quibusdam quia assumenda numquam molestias.</p>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="index.html">Home</a></li>
            <li class="current">Starter Page</li>
          </ol>
        </nav>
      </div>
    </div><!-- End Page Title -->

    <!-- Starter Section Section -->
    <section id="starter-section" class="starter-section section">

      <!-- Section Title -->
      <div class="container section-title" data-aos="fade-up">
        <h2>Starter Section</h2>
        <p>Starter Section<br></p>
      </div><!-- End Section Title -->

      <div class="container" data-aos="fade-up">
        <p>Use this page as a starter for your own custom pages.</p>
      </div>

    </section><!-- /Starter Section Section -->

  </main>

  <footer id="footer" class="footer">

    <div class="container footer-top">
      <div class="row gy-4">
        <div class="col-lg-4 col-md-6 footer-about">
          <a href="index.html" class="logo d-flex align-items-center">
            <span class="sitename">Restaurantly</span>
          </a>
          <div class="footer-contact pt-3">
            <p>A108 Adam Street</p>
            <p>New York, NY 535022</p>
            <p class="mt-3"><strong>Phone:</strong> <span>+1 5589 55488 55</span></p>
            <p><strong>Email:</strong> <span>info@example.com</span></p>
          </div>
          <div class="social-links d-flex mt-4">
            <a href=""><i class="bi bi-twitter-x"></i></a>
            <a href=""><i class="bi bi-facebook"></i></a>
            <a href=""><i class="bi bi-instagram"></i></a>
            <a href=""><i class="bi bi-linkedin"></i></a>
          </div>
        </div>

        <div class="col-lg-2 col-md-3 footer-links">
          <h4>Useful Links</h4>
          <ul>
            <li><a href="#">Home</a></li>
            <li><a href="#">About us</a></li>
            <li><a href="#">Services</a></li>
            <li><a href="#">Terms of service</a></li>
            <li><a href="#">Privacy policy</a></li>
          </ul>
        </div>

        <div class="col-lg-2 col-md-3 footer-links">
          <h4>Our Services</h4>
          <ul>
            <li><a href="#">Web Design</a></li>
            <li><a href="#">Web Development</a></li>
            <li><a href="#">Product Management</a></li>
            <li><a href="#">Marketing</a></li>
            <li><a href="#">Graphic Design</a></li>
          </ul>
        </div>

        <div class="col-lg-4 col-md-12 footer-newsletter">
          <h4>Our Newsletter</h4>
          <p>Subscribe to our newsletter and receive the latest news about our products and services!</p>
          <form action="forms/newsletter.php" method="post" class="php-email-form">
            <div class="newsletter-form"><input type="email" name="email"><input type="submit" value="Subscribe"></div>
            <div class="loading">Loading</div>
            <div class="error-message"></div>
            <div class="sent-message">Your subscription request has been sent. Thank you!</div>
          </form>
        </div>

      </div>
    </div>

    <div class="container copyright text-center mt-4">
      <p>© <span>Copyright</span> <strong class="px-1 sitename">Restaurantly</strong> <span>All Rights Reserved</span></p>
      <div class="credits">
        <!-- All the links in the footer should remain intact. -->
        <!-- You can delete the links only if you've purchased the pro version. -->
        <!-- Licensing information: https://bootstrapmade.com/license/ -->
        <!-- Purchase the pro version with working PHP/AJAX contact form: [buy-url] -->
        Designed by <a href="https://bootstrapmade.com/">BootstrapMade</a>
      </div>
    </div>

  </footer>

  <!-- Scroll Top -->
  <a href="#" id="scroll-top" class="scroll-top d-flex align-items-center justify-content-center"><i class="bi bi-arrow-up-short"></i></a>

  <!-- Preloader -->
  <div id="preloader"></div>

  <!-- Vendor JS Files -->
  <script src="./assets/vendor/bootstrap/js/popper.min.js"></script>
  <script src="./assets/vendor/bootstrap/js/bootstrap.js"></script>
  <script src="./assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="./assets/vendor/php-email-form/validate.js"></script>
  <script src="./assets/vendor/aos/aos.js"></script>
  <script src="./assets/vendor/glightbox/js/glightbox.min.js"></script>
  <script src="./assets/vendor/imagesloaded/imagesloaded.pkgd.min.js"></script>
  <script src="./assets/vendor/isotope-layout/isotope.pkgd.min.js"></script>
  <script src="./assets/vendor/swiper/swiper-bundle.min.js"></script>

  <!-- Main JS File -->
  <script type="module" src="./assets/js/web/main.js"></script>

</body>

</html>