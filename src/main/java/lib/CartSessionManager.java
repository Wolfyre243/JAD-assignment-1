/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Cart session management utility for getting, saving, and clearing session-based shopping cart
 */
package lib;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import models.Cart;

/**
 * Utility class for managing cart in session
 */
public class CartSessionManager {
    private static final String CART_SESSION_KEY = "userCart";
    
    /**
     * Get cart from session, create new if doesn't exist
     */
    public static Cart getCart(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute(CART_SESSION_KEY);
        
        if (cart == null) {
            cart = new Cart();
            session.setAttribute(CART_SESSION_KEY, cart);
        }
        
        return cart;
    }
    
    /**
     * Save cart to session (useful after modifications)
     */
    public static void saveCart(HttpServletRequest request, Cart cart) {
        HttpSession session = request.getSession();
        session.setAttribute(CART_SESSION_KEY, cart);
    }
    
    /**
     * Clear cart from session
     */
    public static void clearCart(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(CART_SESSION_KEY);
        }
    }
    
    /**
     * Check if cart exists and is not empty
     */
    public static boolean hasItems(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        
        Cart cart = (Cart) session.getAttribute(CART_SESSION_KEY);
        return cart != null && !cart.isEmpty();
    }
}
