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
    });

    $.getJSON('CartaAdmin.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var CartaAdminArtifact = data;
      App.contracts.CartaAdmin = TruffleContract(CartaAdminArtifact);
    
      // Set the provider for our contract
      App.contracts.CartaAdmin.setProvider(App.web3Provider);
    });

    $.getJSON('CartaHelper.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var CartaHelperArtifact = data;
      App.contracts.CartaHelper = TruffleContract(CartaHelperArtifact);
    
      // Set the provider for our contract
      App.contracts.CartaHelper.setProvider(App.web3Provider);

      // Use our contract to retrieve cartas
      return App.handleGetCartas();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-crear-carta', App.handleCrearCarta);
    $(document).on('click', '.btn-ver-todas-las-cartas', App.handleGetCartas);
    $(document).on('click', '.btn-ver-mis-cartas', App.handleGetMisCartas);
  },

  handleGetCartas() {
    /*const cartas = document.querySelectorAll(".cartas-list");

    for (let i = 0; i < cartas.length; i++) {
        cartas[i].remove();
    }
    Ver como hacer funcionar esto
    */

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

  handleGetMisCartas() {
    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      alert(`Obteniendo cartas de ${account}`);

      App.contracts.CartaFactory.deployed().then(function(instance) {
        cartaInstance = instance;
  
        return cartaInstance.getCartasDe(account);
      }).then(function(cartas) {
        const [descripciones, tipos] = cartas;
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
        return;
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
