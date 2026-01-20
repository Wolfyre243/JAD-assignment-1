/*
 * Name: Goh Yi Xin Karys / Zhang Junkai
 * Admin No: P2424431 / P2429634
 * Class: DIT/FT/2B/01
 * Description: Checkout servlet converting session cart to database order and bookings
 */
package servlets.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;

import lib.SessionManagement;
import lib.CartSessionManager;
import models.Cart;

@WebServlet("/product/checkout")
public class CheckoutServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (!SessionManagement.isLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/auth/login/");
			return;
		}
		response.sendRedirect(request.getContextPath() + "/product/viewCart");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (!SessionManagement.isLoggedIn(request)) {
			response.sendRedirect(request.getContextPath() + "/auth/login/");
			return;
		}

		// Get cart from SESSION
		Cart cart = CartSessionManager.getCart(request);
		if (cart.isEmpty()) {
			response.sendRedirect(request.getContextPath() + "/product/viewCart?msg=empty_cart");
			return;
		}

		// Set params
		double GST = 0.09; // GST multiplier

//		String secretKey = System.getenv("STRIPE_SECRET_KEY");
//    if (secretKey == null || secretKey.trim().isEmpty()) {
//        throw new ServletException("STRIPE_SECRET_KEY environment variable is not set!");
//    }
		Stripe.apiKey = System.getenv("STRIPE_SECRET_KEY");

		try {
			// Build line items from cart (convert price to cents)
			ArrayList<SessionCreateParams.LineItem> lineItems = new ArrayList<>();
			for (Cart.CartItem item : cart.getItems()) {
				// Calc price
				double priceAfterGST = (double) item.getPrice() * (1 + GST);
				long priceInCents = (long) priceAfterGST * 100;

				lineItems.add(
				    SessionCreateParams.LineItem.builder()
				        .setPriceData(
				            SessionCreateParams.LineItem.PriceData.builder()
				                .setCurrency("sgd")
				                .setUnitAmount(priceInCents)
				                .setProductData(
				                    SessionCreateParams.LineItem.PriceData.ProductData.builder()
				                        .setName(item.getServiceName())
				                        .build())
				                .build())
				        .setQuantity((long) item.getQuantity())
				        .build());
			}

			String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
			String successUrl = baseUrl + "/product/payment-success?session_id={CHECKOUT_SESSION_ID}";
			String cancelUrl = baseUrl + "/product/payment-cancel";
			
			// Create Checkout Session
			SessionCreateParams params = SessionCreateParams.builder()
			    .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
			    .setMode(SessionCreateParams.Mode.PAYMENT)
			    .setSuccessUrl(successUrl)
			    .setCancelUrl(cancelUrl)
			    .addAllLineItem(lineItems)
			    .build();

			Session session = Session.create(params);
			response.sendRedirect(session.getUrl());

		} catch (StripeException e) {
			e.printStackTrace();
			request.setAttribute("error", "Payment error: " + e.getMessage());
			request.getRequestDispatcher("/WEB-INF/components/product/viewCart.jsp").forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("error", "Internal server error");
			request.getRequestDispatcher("/WEB-INF/components/product/viewCart.jsp").forward(request, response);
		}
	}
}