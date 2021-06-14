App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    var version = web3.version.api;
    console.log(version);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('CartaFactory.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var CartaFactoryArtifact = data;
      App.contracts.CartaFactory = TruffleContract(CartaFactoryArtifact);
    
      // Set the provider for our contract
      App.contracts.CartaFactory.setProvider(App.web3Provider);
    
      // Use our contract to retrieve cartas
      return App.handleGetCartas();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-crear', App.handleCrearCarta);
  },

  bindEvents: function() {
    $(document).on('click', '.btn-ver-cartas', App.handleGetCartas);
  },

  handleGetCartas() {
    var cartaInstance;
    alert("Handle get cartas");

    App.contracts.CartaFactory.deployed().then(function(instance) {
      cartaInstance = instance;
      alert("Obteniendo cartas...");

      return cartaInstance.getCartas();
    }).then(function(cartas) {
      console.table(cartas);
      for (i = 0; i < cartas.length; i++) {
        console.log(cartas[i]);
        $('.panel-carta').eq(i).find('tipo-carta').text(cartas[i].tipo);
        $('.panel-carta').eq(i).find('descripcion-carta').text(cartas[i].descripcion);
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  getCartas: function() {
    var cartaInstance;

    App.contracts.CartaFactory.deployed().then(function(instance) {
      cartaInstance = instance;
      console.log("Obteniendo cartas...");
      //return cartaInstance.cartas.call();
      return cartaInstance.cartas();
    }).then(function(cartas) {
      for (i = 0; i < cartas.length; i++) {
        console.log(cartas[i]);
        //$('.panel-carta').eq(i).find('button').text('Success').attr('disabled', true);
        $('.panel-carta').eq(i).find('tipo-carta').text(cartas[i].tipo);
        $('.panel-carta').eq(i).find('descripcion-carta').text(cartas[i].descripcion);
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleCrearCarta: function(event) {
    event.preventDefault();

    var CartaInstance;
    alert("Por crear carta...");

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.CartaFactory.deployed().then(function(instance) {
        CartaInstance = instance;

        return CartaInstance.crearCartaAleatoria({from: account});
      }).then(function(result) {
        alert("Carta creada...");
        return App.getCartas();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
