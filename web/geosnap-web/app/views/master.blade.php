<!DOCTYPE html>
<html>
<head>
  <title>GeoSnap Admin</title>

  {{ HTML::style('//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css') }}
  {{ HTML::style('https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css') }}

  <script src="https://code.jquery.com/jquery-2.2.2.min.js" 
    integrity="sha256-36cp2Co+/62rEAAYHLmRCPIych47CvdM+uTBJwSzWjI=" 
    crossorigin="anonymous">
  </script>
</head>
<body>

    <div class="container">
      <!-- Static navbar -->
      <nav class="navbar navbar-default">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">GeoSnap Admin</a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav">
              <!-- <li class="active"><a href="#">Home</a></li> -->
            </ul>
            <ul class="nav navbar-nav navbar-right">
              <li><a href="./">Log out</a></li>
              <!-- <li>Log out</li> -->
            </ul>
          </div><!--/.nav-collapse -->
        </div><!--/.container-fluid -->
      </nav>

      @yield('body')

    </div> <!-- /container -->

    @yield('javascript')
</body>
</html>