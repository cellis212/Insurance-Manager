// Custom JavaScript for the Insurance Simulation Game

// Custom message handlers for Tech Tree UI updates
$(document).ready(function() {
  
  // Handler to update text content of an element
  Shiny.addCustomMessageHandler("updateText", function(message) {
    $("#" + message.id).text(message.text);
  });
  
  // Handler to add a class to an element
  Shiny.addCustomMessageHandler("updateClass", function(message) {
    if (message.add) {
      $("#" + message.id).addClass(message.add);
    }
    if (message.remove) {
      $("#" + message.id).removeClass(message.remove);
    }
  });
  
  // Handler to show a custom notification
  Shiny.addCustomMessageHandler("showNotification", function(message) {
    var notificationElement = $("<div class='custom-notification " + message.type + "'>" +
                               "<span>" + message.text + "</span>" +
                               "<button class='close-notification'>&times;</button>" +
                               "</div>");
    
    $("body").append(notificationElement);
    
    setTimeout(function() {
      notificationElement.addClass("show");
    }, 100);
    
    // Auto-hide after 5 seconds
    setTimeout(function() {
      notificationElement.removeClass("show");
      setTimeout(function() {
        notificationElement.remove();
      }, 300);
    }, 5000);
    
    // Close button handler
    notificationElement.find(".close-notification").on("click", function() {
      notificationElement.removeClass("show");
      setTimeout(function() {
        notificationElement.remove();
      }, 300);
    });
  });
  
  // Add tooltip initialization for the whole app
  $('[data-toggle="tooltip"]').tooltip();
}); 