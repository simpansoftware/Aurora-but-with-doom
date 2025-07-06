particlesJS.load('particles-js', 'assets/particles.json', function() {
    console.log('callback - particles.js config loaded');
  });


let EWToastify;

function toast(message) {
  if (EWToastify) {
    EWToastify.hideToast();
  }
  EWToastify = Toastify({
    text: message,
    position: 'center',
    style: {
      background: '#333333',
      boxShadow: 'none',
      borderRadius: '20px'
    }
  });
  EWToastify.showToast();
}
/* particlesJS.load(@dom-id, @path-json, @callback (optional)); */
particlesJS.load('particles-js', 'assets/particles.json', function() {
  console.log('callback - particles-js config loaded');
});