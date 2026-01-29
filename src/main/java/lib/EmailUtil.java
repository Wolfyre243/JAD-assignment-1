/*
  Name: Karys Goh Yi Xin
  Admin No: P2424431
  Class: DIT/FT/2B/01
  Date: January 29, 2026 

  Description: Simple email helper using Jakarta Mail.
*/
package lib;

import jakarta.servlet.ServletContext;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailUtil {
  public static void sendEmail(ServletContext ctx, String to, String subject, String body) throws Exception {
    String host = ctx.getInitParameter("mail.smtp.host");
    String port = ctx.getInitParameter("mail.smtp.port");
    String auth = ctx.getInitParameter("mail.smtp.auth");
    String starttls = ctx.getInitParameter("mail.smtp.starttls.enable");
    String username = ctx.getInitParameter("mail.username");
    String password = ctx.getInitParameter("mail.password");
    String from = ctx.getInitParameter("mail.from");

    Properties props = new Properties();
    if (host != null) props.put("mail.smtp.host", host);
    if (port != null) props.put("mail.smtp.port", port);
    if (auth != null) props.put("mail.smtp.auth", auth);
    if (starttls != null) props.put("mail.smtp.starttls.enable", starttls);
    props.put("mail.smtp.connectiontimeout", "10000");
    props.put("mail.smtp.timeout", "10000");

    Session session;
    if ("true".equalsIgnoreCase(auth)) {
      final String u = username;
      final String p = password;
      session = Session.getInstance(props, new jakarta.mail.Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
          return new PasswordAuthentication(u, p);
        }
      });
    } else {
      session = Session.getInstance(props);
    }

    Message msg = new MimeMessage(session);
    if (from != null && !from.trim().isEmpty()) {
      msg.setFrom(new InternetAddress(from, "SilverCare"));
    } else if (username != null && !username.trim().isEmpty()) {
      msg.setFrom(new InternetAddress(username, "SilverCare"));
    } else {
      msg.setFrom(new InternetAddress("noreply@localhost", "SilverCare"));
    }

    msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
    msg.setSubject(subject);
    msg.setText(body);
    msg.setHeader("X-Mailer", "SilverCare-JavaMail");
    msg.setSentDate(new java.util.Date());

    Transport.send(msg);
  }
}
