App = {
  web3Provider: null,
  contracts: {},
  listaCartas: null,
  template: null,


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

    listaCartas = document.querySelector(".cartas-list");
    template = document.getElementById("carta-template");

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
    //alert("Handle get cartas");

    App.contracts.CartaFactory.deployed().then(function(instance) {
      cartaInstance = instance;
      //alert("Obteniendo cartas...");

      return cartaInstance.getCartas.call();
    }).then(function(cartas) {
      const [descripciones, tipos] = cartas;
      console.log("CARTAS")
      console.log(cartas);
      //console.log(descripciones);
      //console.log(tipos);
      tipoCarta = 'Epica';
      for (i = 0; i < descripciones.length; i++) {
        if (tipos[i] == 1) {
          tipoCarta == 'Normal';
        } else if (tipos[i] == 2) {
          tipoCarta == 'Rara';
        }
        const node = App.copyTemplate(tipoCarta, descripciones[i], i);
        listaCartas.appendChild(node);
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  copyTemplate(tipo, descripcion, id) {
    const element = template.cloneNode(true);
    element.id = "carta" + id;
    element.removeAttribute("hidden");
  
    const idElement = element.querySelector(".id-carta span");
    idElement.innerText = id;

    const nameElement = element.querySelector(".tipo-carta b");
    nameElement.innerText = tipo;
  
    const addressElement = element.querySelector(".descripcion-carta b");
    addressElement.innerText = descripcion;
  
    return element;
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
        return App.handleGetCartas();
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
