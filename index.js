// Authenticate the user, and get permission to request payments from them:
var scopes = ['username', 'payments'];

// Read more about this callback in the SDK reference:
function onIncompletePaymentFound(payment) { /* ... */ };

Pi.authenticate(scopes, onIncompletePaymentFound).then(function(auth) {
}).catch(function(error) {
  console.error(error);
});

var axiosClient = axios.create({
  baseURL: "https://pipi-server.herokuapp.com/api",
  timeout: 30000
})

var config = {
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  }
}

async function paste(input) {
  const text = await navigator.clipboard.readText();
  document.getElementById("address").value = text
}

var web3 = new Web3()

function donate() {
  var amount = document.getElementById("amount").value;
  var address = document.getElementById("address").value;
  showWarning()
  // if(!web3.utils.isAddress(address)) return 
    Pi.createPayment({
        // Amount of π to be paid:
        amount: parseFloat(amount),
        // An explanation of the payment - will be shown to the user:
        memo: address,
        // An arbitrary developer-provided metadata object - for your own usage:
        metadata: { 
          bsc_address: address
         }
      }, {
        // Callbacks you need to implement - read more about those in the detailed docs linked below:
        onReadyForServerApproval: function(paymentId) {
          console.log({paymentId})
          document.getElementById('paymentId').value = paymentId
          axiosClient.post(`/payments/${paymentId}/approve`, {}, config)
          .then(function (response) {
            console.log(response);
          })
          .catch(function (error) {
            console.log(error);
          });
        },
        onReadyForServerCompletion: function(paymentId, txid) {
          console.log({paymentId, txid})
          document.getElementById('paymentId').value = paymentId
          document.getElementById('txid').value = txid
          axiosClient.post(`/payments/${paymentId}/complete`, {
            txid: txid
          })
          .then(function (response) {
            console.log(response);
          })
          .catch(function (error) {
            console.log(error);
          });
        },
        onCancel: function(paymentId) { 
            alert(`User cancelled the payment`)
         },
        onError: function(error, payment) { 
         },
      });
}

const html5QrCode = new Html5Qrcode(/* element id */ "reader");
// File based scanning
const fileinput = document.getElementById('qr-input-file');
fileinput.addEventListener('change', e => {
  if (e.target.files.length == 0) {
    // No file selected, ignore 
    return;
  }
  
  const imageFile = e.target.files[0];
  // Scan QR Code
  html5QrCode.scanFile(imageFile, true)
  .then(decodedText => {
    // success, use decodedText
    let address
    if(decodedText.indexOf(':') > 0) {
      address = decodedText.split(":")[1]
    } else {
      address = decodedText
    }
    document.getElementById("address").value = address
  })
  .catch(err => {
    // failure, handle it.
    console.log(`Error scanning file. Reason: ${err}`)
  });
});

function showWarning() {
  var warning = document.getElementById("warning")
  var address = document.getElementById("address").value
  var isValid = web3.utils.isAddress(address)
  console.log({
    isValid,
    address
  })
  if(isValid) {
    warning.style.display = 'none'
  } else {
    warning.style.display = 'block'
  }
}
