if (window.location.href.includes('mood') == false) {

  const style = document.createElement('style');
  style.innerHTML = `
    @keyframes fadeOut {
        100% {
            opacity: 0;
            visibility: hidden
        }
    }
    
    .loader {
        --background: linear-gradient(135deg, #23C4F8, #275EFE);
        --shadow: rgba(39, 94, 254, 0.28);
        --text: #6C7486;
        --page: rgba(255, 255, 255, 0.36);
        --page-fold: rgba(255, 255, 255, 0.52);
        --duration: 3s;
        width: 200px;
        height: 140px;
        position: relative;
    }
    
    .loader:before,
    .loader:after {
        --r: -6deg;
        content: '';
        position: absolute;
        bottom: 8px;
        width: 120px;
        top: 80%;
        box-shadow: 0 16px 12px var(--shadow);
        -webkit-transform: rotate(var(--r));
        transform: rotate(var(--r));
    }
    
    .loader:before {
        left: 4px;
    }
    
    .loader:after {
        --r: 6deg;
        right: 4px;
    }
    
    .loader div {
        width: 100%;
        height: 100%;
        border-radius: 13px;
        position: relative;
        z-index: 1;
        -webkit-perspective: 600px;
        perspective: 600px;
        box-shadow: 0 4px 6px var(--shadow);
        background-image: var(--background);
    }
    
    .loader div ul {
        margin: 0;
        padding: 0;
        list-style: none;
        position: relative;
    }
    
    .loader div ul li {
        --r: 180deg;
        --o: 0;
        --c: var(--page);
        position: absolute;
        top: 10px;
        left: 10px;
        -webkit-transform-origin: 100% 50%;
        transform-origin: 100% 50%;
        color: var(--c);
        opacity: var(--o);
        -webkit-transform: rotateY(var(--r));
        transform: rotateY(var(--r));
        -webkit-animation: var(--duration) ease infinite;
        animation: var(--duration) ease infinite;
    }
    
    .loader div ul li:nth-child(2) {
        --c: var(--page-fold);
        -webkit-animation-name: page-2;
        animation-name: page-2;
    }
    
    .loader div ul li:nth-child(3) {
        --c: var(--page-fold);
        -webkit-animation-name: page-3;
        animation-name: page-3;
    }
    
    .loader div ul li:nth-child(4) {
        --c: var(--page-fold);
        -webkit-animation-name: page-4;
        animation-name: page-4;
    }
    
    .loader div ul li:nth-child(5) {
        --c: var(--page-fold);
        -webkit-animation-name: page-5;
        animation-name: page-5;
    }
    
    .loader div ul li svg {
        width: 90px;
        height: 120px;
        display: block;
    }
    
    .loader div ul li:first-child {
        --r: 0deg;
        --o: 1;
    }
    
    .loader div ul li:last-child {
        --o: 1;
    }
    
    .loader span {
        display: block;
        left: 0;
        right: 0;
        top: 100%;
        margin-top: 20px;
        text-align: center;
        color: var(--text);
    }
    
    @-webkit-keyframes page-2 {
        0% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        20% {
            opacity: 1;
        }
        35%,
        100% {
            opacity: 0;
        }
        50%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @keyframes page-2 {
        0% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        20% {
            opacity: 1;
        }
        35%,
        100% {
            opacity: 0;
        }
        50%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @-webkit-keyframes page-3 {
        15% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        35% {
            opacity: 1;
        }
        50%,
        100% {
            opacity: 0;
        }
        65%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @keyframes page-3 {
        15% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        35% {
            opacity: 1;
        }
        50%,
        100% {
            opacity: 0;
        }
        65%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @-webkit-keyframes page-4 {
        30% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        50% {
            opacity: 1;
        }
        65%,
        100% {
            opacity: 0;
        }
        80%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @keyframes page-4 {
        30% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        50% {
            opacity: 1;
        }
        65%,
        100% {
            opacity: 0;
        }
        80%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @-webkit-keyframes page-5 {
        45% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        65% {
            opacity: 1;
        }
        80%,
        100% {
            opacity: 0;
        }
        95%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    @keyframes page-5 {
        45% {
            -webkit-transform: rotateY(180deg);
            transform: rotateY(180deg);
            opacity: 0;
        }
        65% {
            opacity: 1;
        }
        80%,
        100% {
            opacity: 0;
        }
        95%,
        100% {
            -webkit-transform: rotateY(0deg);
            transform: rotateY(0deg);
        }
    }
    
    html {
        box-sizing: border-box;
        -webkit-font-smoothing: antialiased;
    }
    
    * {
        box-sizing: inherit;
    }
    
    *:before,
    *:after {
        box-sizing: inherit;
    }
    
    body {
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background: #1C212E;
        font-family: 'Roboto', Arial;
    }
    
    body .dribbble {
        position: fixed;
        display: block;
        right: 24px;
        bottom: 24px;
    }
    
    body .dribbble img {
        display: block;
        width: 76px;
    }
    `;
  document.head.appendChild(style);
  const div = document.createElement('div');
  div.className = 'a1';
  div.innerHTML = '<div class="loader"><div><ul><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li><li><svg viewBox="0 0 90 120" fill="currentColor"><path d="M90,0 L90,120 L11,120 C4.92486775,120 0,115.075132 0,109 L0,11 C0,4.92486775 4.92486775,0 11,0 L90,0 Z M71.5,81 L18.5,81 C17.1192881,81 16,82.1192881 16,83.5 C16,84.8254834 17.0315359,85.9100387 18.3356243,85.9946823 L18.5,86 L71.5,86 C72.8807119,86 74,84.8807119 74,83.5 C74,82.1745166 72.9684641,81.0899613 71.6643757,81.0053177 L71.5,81 Z M71.5,57 L18.5,57 C17.1192881,57 16,58.1192881 16,59.5 C16,60.8254834 17.0315359,61.9100387 18.3356243,61.9946823 L18.5,62 L71.5,62 C72.8807119,62 74,60.8807119 74,59.5 C74,58.1192881 72.8807119,57 71.5,57 Z M71.5,33 L18.5,33 C17.1192881,33 16,34.1192881 16,35.5 C16,36.8254834 17.0315359,37.9100387 18.3356243,37.9946823 L18.5,38 L71.5,38 C72.8807119,38 74,36.8807119 74,35.5 C74,34.1192881 72.8807119,33 71.5,33 Z"></path></svg></li></ul></div> <span style="color: #23C4F8"></span> </div>';
  document.querySelector('.loader-wrapper').appendChild(div);

} else {
  const style = document.createElement('style');
  style.innerHTML = `
   .a2 {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
}

.dash {
  margin: 0 15px;
  width: 35px;
  height: 15px;
  border-radius: 8px;
  background: #45abfd;
  box-shadow: 0 0 5px 0 #65cdfd;
}

.uno {
  margin-right: -18px;
  transform-origin: center left;
  animation: spin 3s linear infinite;  
}

.dos {
  transform-origin: center right;
  animation: spin2 3s linear infinite;
  animation-delay: .2s;
}

.tres {
  transform-origin: center right;
  animation: spin3 3s linear infinite;
  animation-delay: .3s;
}

.cuatro {
  transform-origin: center right;
  animation: spin4 3s linear infinite;
  animation-delay: .4s;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  25% {
    transform: rotate(360deg);
  }
  30% {
    transform: rotate(370deg);
  }
  35% {
    transform: rotate(360deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes spin2 {
  0% {
    transform: rotate(0deg);
  }
  20% {
    transform: rotate(0deg);
  }
  30% {
    transform: rotate(-180deg);
  }
  35% {
    transform: rotate(-190deg);
  }
  40% {
    transform: rotate(-180deg);
  }
  78% {
    transform: rotate(-180deg);
  }
  95% {
    transform: rotate(-360deg);
  }
  98% {
    transform: rotate(-370deg);
  }
  100% {
    transform: rotate(-360deg);
  }
}

@keyframes spin3 {
  0% {
    transform: rotate(0deg);
  }
  27% {
    transform: rotate(0deg);  
  }
  40% {
    transform: rotate(180deg);
  }
  45% {
    transform: rotate(190deg);
  }
  50% {
    transform: rotate(180deg);
  }
  62% {
    transform: rotate(180deg);
  }
  75% {
    transform: rotate(360deg);
  }
  80% {
    transform: rotate(370deg);
  }
  85% {
    transform: rotate(360deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes spin4 {
  0% {
    transform: rotate(0deg);
  }
  38% {
    transform: rotate(0deg);
  }
  60% {
    transform: rotate(-360deg);
  }
  65% {
    transform: rotate(-370deg);
  }
  75% {
    transform: rotate(-360deg);
  }
  100% {
    transform: rotate(-360deg);
  }
}
    `;

  document.head.appendChild(style);

  const div = document.createElement('div');
  div.className = 'a1';
  div.innerHTML = '<div class="a2"><div class="dash uno"></div><div class="dash dos"></div><div class="dash tres"></div><div class="dash cuatro"></div></div>';
  document.querySelector('.loader-wrapper').appendChild(div);
}
