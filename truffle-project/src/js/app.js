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
    template = document.querySelector("template");

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('CartaItem.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var CartaItemArtifact = data;
      App.contracts.CartaItem = TruffleContract(CartaItemArtifact);
    
      // Set the provider for our contract
      App.contracts.CartaItem.setProvider(App.web3Provider);

      // Use our contract to retrieve cartas
      return App.handleInitPage();
    });

    $.getJSON('CartaHelper.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var CartaHelperArtifact = data;
      App.contracts.CartaHelper = TruffleContract(CartaHelperArtifact);
    
      // Set the provider for our contract
      App.contracts.CartaHelper.setProvider(App.web3Provider);
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-clean', App.handleClean);
    $(document).on('click', '.btn-crear-carta', App.handleCrearCarta);
    $(document).on('click', '.btn-ver-todas-las-cartas', App.handleGetCartas);
    $(document).on('click', '.btn-ver-mis-cartas', App.handleGetMisCartas);
    $(document).on('click', '.btn-ver-mis-tokens', App.handleVerCantidadTokens);

    $(document).on('submit', '.form-transferencia', App.handleTransferirCarta);
  },

  handleInitPage() {
    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      console.log(`Obteniendo balance de ${account}`);

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaInstance = instance;
  
        return cartaInstance.balanceOzToken({from: account});
      }).then(function(balance) {
        console.log(`La cantidad de tokens (OZT) disponibles es de: ${balance}`);
        $('.balance-oz').text(`Tokens: ${balance}`);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleClean() {
    location.reload();
  },

  handleGetCartas() {
    //TODO mostrar duenio
    var cartaInstance;

    App.contracts.CartaItem.deployed().then(function(instance) {
      cartaInstance = instance;

      return cartaInstance.getCartas.call();
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
  },

  handleGetMisCartas() {
    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      alert(`Obteniendo cartas de ${account}`);

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaInstance = instance;
  
        return cartaInstance.getCartasDe(account);
      }).then(function(cartas) {
        const [ids, descripciones, tipos] = cartas;
        tipoCarta = 'Epica';
        console.log(ids);
        
        for (i = 0; i < descripciones.length; i++) {
          if (tipos[i] == 1) {
            tipoCarta == 'Normal';
          } else if (tipos[i] == 2) {
            tipoCarta == 'Rara';
          }
          const node = App.copyTemplate(tipoCarta, descripciones[i], ids[i]);
          listaCartas.appendChild(node);
        }
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  copyTemplate(tipo, descripcion, id) {
    const cartaTemplate = document.importNode(template.content, true);

    const element = cartaTemplate.querySelector(".carta");
    element.id = "carta" + id;
  
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

    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaInstance = instance;
        console.log(`Account ${account}`);

        return cartaInstance.crearCartaAleatoria({from: account});
      }).then(function(result) {
        alert(`Carta ${result} creada`);
        location.reload();
        return;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleTransferirCarta: function(event) {
    event.preventDefault();
    var data = $("#form-transferencia :input").serializeArray();

    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      var direccionDestino = data[0].value;  
      var cartaId = data[1].value;  

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaInstance = instance;
        
        return cartaInstance.transfer(direccionDestino, cartaId, {from: account});
      }).then(function(result) {
        alert(`Carta ${cartaId} transferida de ${account} a ${direccionDestino}`);
        location.reload();
        return;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleVerCantidadTokens: function() {
    var cartaInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      alert(`Obteniendo balance de ${account}`);

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaInstance = instance;
  
        return cartaInstance.balanceOzToken({from: account});
      }).then(function(balance) {
        alert(`La cantidad de tokens (OZT) disponibles es de: ${balance}`);
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
