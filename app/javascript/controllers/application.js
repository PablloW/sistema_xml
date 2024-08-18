import { Application } from "@hotwired/stimulus";
import Rails from "https://cdn.jsdelivr.net/npm/@rails/ujs@7.0.0/lib/assets/compiled/rails-ujs.js";
Rails.start();

// Configuração do Stimulus
application.debug = false;
window.Stimulus = application;

export { application };
