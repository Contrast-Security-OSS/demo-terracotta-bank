<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="keywords" content="">
    <meta name="description" content="">

    <title>Error - Terracotta Bank</title>

    <!-- stylesheet css -->
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/font-awesome.min.css">
    <link rel="stylesheet" href="css/nivo-lightbox.css">
    <link rel="stylesheet" href="css/nivo_themes/default/default.css">
    <link rel="stylesheet" href="css/style.css">
    <!-- google web font css -->
    <link href='http://fonts.googleapis.com/css?family=Raleway:400,300,600,700' rel='stylesheet' type='text/css'>
    <style>
        body { 
            padding-top: 100px; /* Adjust this value to suit your navbar's height */
        }
    </style>
</head>

<body data-page-context="${pageContext.request.contextPath}" data-spy="scroll" data-target=".navbar-collapse">

<!-- navigation -->
<div class="navbar navbar-default navbar-fixed-top" role="navigation">
	<div class="container">
		<div class="navbar-header">
			<button class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
				<span class="icon icon-bar"></span>
				<span class="icon icon-bar"></span>
				<span class="icon icon-bar"></span>
			</button>
			<a href="#home" class="navbar-brand smoothScroll">Terracotta</a>
		</div>
		<div class="collapse navbar-collapse">
			<ul class="nav navbar-nav navbar-right">
				<c:choose>
					<c:when test="${empty authenticatedUser}">
						<li><a href="#home" class="smoothScroll">HOME</a></li>
						<li><a href="#login" class="smoothScroll">LOGIN</a></li>
					</c:when>
					<c:otherwise>
						<li><a href="#service" class="smoothScroll">HOME</a></li>
						<c:if test="${authenticatedUser.admin}">
						<li style="background-color: #dc5034;"><a href="/employee.jsp" class="smoothScroll">ADMIN</a></li>
						</c:if>
						<c:if test="${authenticatedUser.username eq 'system'}">
						<li style="background-color: #dc5034;"><a href="/siteStatistics" class="smoothScroll">BACKOFFICE</a></li>
						</c:if>
						<li><a href="${pageContext.request.contextPath}/logout">LOGOUT</a></li>
					</c:otherwise>
				</c:choose>
				<li><a href="#contact" class="smoothScroll">CONTACT</a></li>
				<li><a href="#about" class="smoothScroll">ABOUT</a></li>
			</ul>
		</div>
	</div>
</div>		

<!-- error section -->
<div id="error">
    <div class="container">
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <h2>Oops! Something went wrong.</h2>
            </div>
        </div>
    </div>
</div>

<!-- footer section -->
<footer>
	<div class="container">
		<div class="row">
			<div class="col-md-6 col-sm-6">
				<h2>Our Office</h2>
				<p>101 Terracotta Row, San Francisco, CA 10110</p>
				<p>Email: <span>vases@terracottabank.com</span></p>
				<p>Phone: <span>010-020-0340</span></p>
			</div>
			<div class="col-md-6 col-sm-6">
				<h2>Social Us</h2>
				<ul class="social-icons">
					<li><a href="#" class="fa fa-facebook"></a></li>
					<li><a href="#" class="fa fa-twitter"></a></li>
                    <li><a href="#" class="fa fa-google-plus"></a></li>
					<li><a href="#" class="fa fa-dribbble"></a></li>
				</ul>
			</div>
		</div>
	</div>
</footer>

<!-- divider section -->
<div class="container">
	<div class="row">
		<div class="col-md-1 col-sm-1"></div>
		<div class="col-md-10 col-sm-10">
			<hr>
		</div>
		<div class="col-md-1 col-sm-1"></div>
	</div>
</div>

<!-- copyright section -->
<div class="copyright">
	<div class="container">
		<div class="row">
			<div class="col-md-12 col-sm-12">
				<p>Copyright &copy; 2016 Minimax Digital Firm 
                
                - Design: <a rel="nofollow" href="http://www.tooplate.com" target="_parent">Tooplate</a></p>
			</div>
		</div>
	</div>
</div>

<!-- scrolltop section -->
<a href="#top" class="go-top"><i class="fa fa-angle-up"></i></a>


<!-- javascript js -->	
<script src="https://code.jquery.com/jquery-3.1.1.js"
			  integrity="sha256-16cdPddA6VdVInumRGo6IbivbERE8p7CQR3HzTBuELA="
			  crossorigin="anonymous"></script>
<script src="js/bootstrap.min.js"></script>	
<script src="js/nivo-lightbox.min.js"></script>
<script src="js/jquery.nav.js"></script>
<script src="js/isotope.js"></script>
<script src="js/imagesloaded.min.js"></script>
<script src="js/custom.js"></script>
<script src="js/forms.js"></script>
</body>
</html>
