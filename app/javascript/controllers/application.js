import { Application } from "@hotwired/stimulus";
import Rails from "@rails/ujs";
Rails.start();

// Configuração do Stimulus
application.debug = false;
window.Stimulus = application;

export { application };
