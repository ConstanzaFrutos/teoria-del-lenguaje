App = {
  web3Provider: null,
  contracts: {},
  listaCartas: null,
  subastaActual : null,
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
    subasta = document.querySelector(".cartas-list");
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

    $.getJSON('SubastaFactory.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var SubastaFactoryArtifact = data;
      App.contracts.SubastaFactory = TruffleContract(SubastaFactoryArtifact);

      // Set the provider for our contract
      App.contracts.SubastaFactory.setProvider(App.web3Provider);
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
    
    $(document).on('click', '.btn-obtener-subastas-en-curso', App.handleObtenerSubastasEnCurso);
    $(document).on('click', '.btn-comenzar-subasta', App.handleComenzarSubasta);
    $(document).on('click', '.btn-cancelar-subasta', App.handleCancelarSubasta);
    $(document).on('click', '.btn-ofertar-subasta', App.handleOfertarSubasta);
    $(document).on('click', '.btn-retirar-subasta', App.handleRetirarFondosEnSubasta);
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
        $('.cuenta-actual-nombre').text(`Nombre cuenta actual: ${account}`);
        $('.cuenta-actual-direccion').text(`Dirección cuenta actual: ${account}`);
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

  // Subasta

  loadSubastaEnCurso: function (subastaId, duenio, cartaId, tiempoInicial, tiempoFinal, incrementoMinimo, cancelada) {
    let template = $(".subasta-en-curso").clone();
    template.removeClass('subasta-en-curso');
    template.removeAttr('hidden');
    template.addClass('subasta-en-curso-clone');

    template.find("p.subasta-en-curso-id-subasta").html("Id de la subasta : " + subastaId);
    template.find("p.subasta-en-curso-duenio").html("Dueño de la subasta: " + duenio);
    template.find("p.subasta-en-curso-id-carta").html("Id de la carta: " + cartaId);
    template.find("p.subasta-en-curso-tiempo-inicial").html("Tiempo inicial: " + tiempoInicial);
    template.find("p.subasta-en-curso-tiempo-final").html("Tiempo final: " + tiempoFinal);
    template.find("p.subasta-en-curso-incremento-minimo").html("Incremento mínimo: " + incrementoMinimo);
    
    if (!cancelada){
      template.find("p.button-cancelar").html('<button class="btn btn-default btn-cancelar-subasta" type="button" data-id="' + subastaId + '">Cancelar Subasta</button>');
    }else{
      template.find("p.subasta-estado-cancelado").html('<p class="texto-rojo" > Esta subasta esta cancelada </p>');
    }
    template.find("p.button-retirar-fondos").html('<button class="btn btn-default btn-retirar-subasta" type="button" data-id="' + subastaId + '">Retirar Fondos</button>');
    template.appendTo(".lista-subastas-en-curso");
  },

  handleObtenerSubastasEnCurso: function(event) {

    var subastaFactoryInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      alert(`Obteniendo subastas en curso`);

      App.contracts.SubastaFactory.deployed().then(function(instance) {
        subastaFactoryInstance = instance;
  
        return subastaFactoryInstance.getIdSubastasDisponibles();
      }).then(function(subastas) {
        console.log(subastas);
        $(".lista-subastas-en-curso").empty();

        let subastasPromise = [];
        for (i = 0; i < subastas.length; i++) {
          console.log(subastas[i]*1);
          subastasPromise.push(subastaFactoryInstance.subastas(subastas[i]*1));
        }
      
        Promise.all(subastasPromise).then(subastas => {
          subastas.forEach(subasta => {
            let subastaId = subasta[0] * 1;
            let duenio = subasta[1];
            let cartaId = subasta[2] * 1;
            let tiempoInicial = subasta[3] * 1;
            let tiempoFinal = subasta[4] * 1;
            let incrementoMinimo = subasta[5] * 1;
            let cancelada = subasta[6];

            App.loadSubastaEnCurso(subastaId, duenio, cartaId, tiempoInicial, tiempoFinal, incrementoMinimo, cancelada);
          });
        }).catch(function(err) {
          console.log(err.message);
        });
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleComenzarSubasta: function(event) {
    event.preventDefault();

    var data = $("#form-subasta :input").serializeArray();
    var cartaItemInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      var cartaId = data[0].value;
      var incrementoMinimo = data[1].value;
      var tiempoInicial = data[2].value;
      var tiempoFinal = data[3].value;

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaItemInstance = instance;

        return cartaItemInstance.subastarCarta(account, cartaId, incrementoMinimo, tiempoInicial, tiempoFinal, {from:account});
      }).then(function(result) {
        event.preventDefault();
        alert(`La subasta ${result} fue creada`);
      }).catch(function(err) {
        alert(err.message);
      });
    });
  },

  handleCancelarSubasta: function(event) {

    event.preventDefault();

    var cartaItemInstance;
    let idSubasta = $(this).attr("data-id");
    alert(`Cancelando la subasta ${idSubasta}`);

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      
      var account = accounts[0];

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaItemInstance = instance;

        return cartaItemInstance.cancelarSubasta(idSubasta, {from: account});
      }).then(function(result) {
        alert(`Subasta cancelada`);
        location.reload();
        return;
      }).catch(function(err) {
        console.log(err.message);
      });
    });

  },

  handleOfertarSubasta: function(event) {

    event.preventDefault();

    var cartaItemInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      let idSubasta = document.getElementById("id-subasta-oferta").value;
      let montoAOfertar = document.getElementById("cantidad-a-ofertar").value;
      console.log(montoAOfertar);

      App.contracts.CartaItem.deployed().then(function(instance) {
        cartaItemInstance = instance;
        console.log(montoAOfertar);

        return cartaItemInstance.ofertarCarta(idSubasta, montoAOfertar ,{from: account});
      }).then(function(result) {
        alert(`usted oferto  ${montoAOfertar} para la subasta ${idSubasta}`);
        return;
      }).catch(function(err) {
        console.log(err.message);
      });
    });

  },

  handleRetirarFondosEnSubasta: function(event) {

    event.preventDefault();

    var cartaItemInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      let idSubasta = document.getElementById("data-id").value;

      App.contracts.cartaItem.deployed().then(function(instance) {
        cartaItemInstance = instance;

        return cartaItemInstance.retirarFondos( idSubasta, {from: account, payable});
      }).then(function(result) {
        alert(`usted retiro su oferta de la subasta ${idSubasta}`);
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
