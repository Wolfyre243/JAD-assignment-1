/*
 * Name: Goh Yi Xin Karys
 * Admin No: P2424431
 * Class: DIT/FT/2B/01
 * Description: Session-based shopping cart model with item management, quantity updates, and total calculations
 */
package models;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Cart model for session-based cart management
 * Stores cart items in memory (HttpSession) instead of database
 */
public class Cart implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private List<CartItem> items;
    
    public Cart() {
        this.items = new ArrayList<>();
    }
    
    /**
     * Add item to cart or update quantity if already exists
     * For products with additional details (caregiver, client, special requests, timeslot)
     */
    public void addItem(int serviceId, String serviceName, double price, int quantity, 
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot) {
        // For items with special attributes, always add as new item
        // (even if same serviceId, different caregiver/client/requests = different booking)
        items.add(new CartItem(serviceId, serviceName, price, quantity, 
                              caregiverId, clientId, specialRequests, timeslot, null));
    }

    /**
     * Add item with explicit end timeslot
     */
    public void addItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot, String timeslotEnd) {
        items.add(new CartItem(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, timeslot, timeslotEnd));
    }

    /**
     * Add item with explicit availability id (from caregiver_availability)
     */
    public void addItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot, String timeslotEnd, Integer availabilityId) {
        items.add(new CartItem(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, timeslot, timeslotEnd, availabilityId));
    }
    
    /**
     * Add item to cart without timeslot (backward compatibility)
     */
    public void addItem(int serviceId, String serviceName, double price, int quantity, 
                       Integer caregiverId, Integer clientId, String specialRequests) {
        addItem(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, null);
    }
    
    /**
     * Add simple item to cart or update quantity if already exists
     */
    public void addItem(int serviceId, String serviceName, double price, int quantity) {
        addItem(serviceId, serviceName, price, quantity, null, null, null);
    }
    
    /**
     * Update quantity for a specific item
     */
    public boolean updateQuantity(int serviceId, int newQuantity) {
        if (newQuantity <= 0) {
            return removeItem(serviceId);
        }
        
        Optional<CartItem> item = findItem(serviceId);
        if (item.isPresent()) {
            item.get().setQuantity(newQuantity);
            return true;
        }
        return false;
    }
    
    /**
     * Remove item from cart by index (for items with same serviceId but different attributes)
     */
    public boolean removeItemByIndex(int index) {
        if (index >= 0 && index < items.size()) {
            items.remove(index);
            return true;
        }
        return false;
    }
    
    /**
     * Remove item from cart by serviceId (removes first match)
     */
    public boolean removeItem(int serviceId) {
        return items.removeIf(item -> item.getServiceId() == serviceId);
    }
    
    /**
     * Clear all items from cart
     */
    public void clear() {
        items.clear();
    }
    
    /**
     * Get all cart items
     */
    public List<CartItem> getItems() {
        return new ArrayList<>(items); // Return copy to prevent external modification
    }
    
    /**
     * Get total number of items in cart
     */
    public int getItemCount() {
        return items.stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }
    
    /**
     * Calculate total price
     */
    public double getTotal() {
        return items.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();
    }
    
    /**
     * GST rate for Singapore (9%)
     */
    private static final double GST_RATE = 0.09;
    
    /**
     * Get subtotal (before GST)
     */
    public double getSubtotal() {
        return getTotal();
    }
    
    /**
     * Get GST amount
     */
    public double getGSTAmount() {
        return getSubtotal() * GST_RATE;
    }
    
    /**
     * Get total including GST
     */
    public double getTotalWithGST() {
        return getSubtotal() + getGSTAmount();
    }
    
    /**
     * Check if GST applies (for eldercare services in Singapore, GST typically applies)
     */
    public boolean isGSTApplicable() {
        return true; // GST applies to most eldercare services in Singapore
    }
    
    /**
     * Check if cart is empty
     */
    public boolean isEmpty() {
        return items.isEmpty();
    }
    
    /**
     * Find item by service ID
     */
    private Optional<CartItem> findItem(int serviceId) {
        return items.stream()
                .filter(item -> item.getServiceId() == serviceId)
                .findFirst();
    }
    
    /**
     * Inner class representing a single cart item
     */
    public static class CartItem implements Serializable {
        private static final long serialVersionUID = 1L;
        
        private int serviceId;
        private String serviceName;
        private double price;
        private int quantity;
        private Integer caregiverId;
        private Integer clientId;
        private Integer availabilityId;
        private String specialRequests;
        private String timeslot;
        private String timeslotEnd;
        
        public CartItem(int serviceId, String serviceName, double price, int quantity) {
            this(serviceId, serviceName, price, quantity, null, null, null, null);
        }
        
        public CartItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests) {
            this(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, null);
        }

        // Backwards-compatible constructor (8 parameters) kept for existing code
        public CartItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot) {
            this(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, timeslot, null);
        }
        
        public CartItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot, String timeslotEnd) {
            this.serviceId = serviceId;
            this.serviceName = serviceName;
            this.price = price;
            this.quantity = quantity;
            this.caregiverId = caregiverId;
            this.clientId = clientId;
            this.specialRequests = specialRequests;
            this.timeslot = timeslot;
            this.timeslotEnd = timeslotEnd;
        }

        public CartItem(int serviceId, String serviceName, double price, int quantity,
                       Integer caregiverId, Integer clientId, String specialRequests, String timeslot, String timeslotEnd, Integer availabilityId) {
            this(serviceId, serviceName, price, quantity, caregiverId, clientId, specialRequests, timeslot, timeslotEnd);
            this.availabilityId = availabilityId;
        }

        public Integer getAvailabilityId() {
            return availabilityId;
        }

        public void setAvailabilityId(Integer availabilityId) {
            this.availabilityId = availabilityId;
        }

        public String getTimeslotEnd() {
            return timeslotEnd;
        }

        public void setTimeslotEnd(String timeslotEnd) {
            this.timeslotEnd = timeslotEnd;
        }
        
        // Getters and setters
        public int getServiceId() {
            return serviceId;
        }
        
        public void setServiceId(int serviceId) {
            this.serviceId = serviceId;
        }
        
        public String getServiceName() {
            return serviceName;
        }
        
        public void setServiceName(String serviceName) {
            this.serviceName = serviceName;
        }
        
        public double getPrice() {
            return price;
        }
        
        public void setPrice(double price) {
            this.price = price;
        }
        
        public int getQuantity() {
            return quantity;
        }
        
        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }
        
        public Integer getCaregiverId() {
            return caregiverId;
        }
        
        public void setCaregiverId(Integer caregiverId) {
            this.caregiverId = caregiverId;
        }
        
        public Integer getClientId() {
            return clientId;
        }
        
        public void setClientId(Integer clientId) {
            this.clientId = clientId;
        }
        
        public String getSpecialRequests() {
            return specialRequests;
        }
        
        public void setSpecialRequests(String specialRequests) {
            this.specialRequests = specialRequests;
        }
        
        public String getTimeslot() {
            return timeslot;
        }
        
        public void setTimeslot(String timeslot) {
            this.timeslot = timeslot;
        }
        
        public double getSubtotal() {
            return price * quantity;
        }
    }
}
