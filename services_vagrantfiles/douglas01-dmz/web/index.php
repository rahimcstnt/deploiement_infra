<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>blanc.iut</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 50%, #16213e 100%);
            color: white;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Header */
        header {
            background: rgba(0,0,0,0.3);
            backdrop-filter: blur(20px);
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        nav {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
            justify-content: center;
        }

        .logo {
            font-size: 2.5rem;
            font-weight: 900;
            letter-spacing: 5px;
            background: linear-gradient(45deg, #00f5ff, #ff00ff, #00ff88);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-shadow: 0 0 30px rgba(0, 255, 255, 0.5);
            animation: glow 2s ease-in-out infinite alternate;
        }

        @keyframes glow {
            from { filter: drop-shadow(0 0 10px #00f5ff); }
            to { filter: drop-shadow(0 0 20px #ff00ff); }
        }

        /* Main Content */
        .main {
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 2rem;
        }

        .title {
            font-size: 8rem;
            font-weight: 900;
            margin-bottom: 2rem;
            background: linear-gradient(45deg, #00f5ff, #ff00ff, #00ff88, #ffaa00);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: titleFloat 4s ease-in-out infinite;
            text-shadow: 0 0 50px rgba(0, 255, 255, 0.3);
        }

        @keyframes titleFloat {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .subtitle {
            font-size: 1.5rem;
            opacity: 0.8;
            margin-bottom: 4rem;
            animation: fadeIn 2s ease-out 0.5s both;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 0.8; transform: translateY(0); }
        }

        /* Formulaire */
        .form-container {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 25px;
            padding: 3rem;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 25px 50px rgba(0,0,0,0.5);
            animation: slideUp 1s ease-out 1s both;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 1.2rem 1rem;
            background: rgba(255,255,255,0.1);
            border: 2px solid rgba(0, 255, 255, 0.3);
            border-radius: 15px;
            color: white;
            font-size: 1rem;
            transition: all 0.3s;
            backdrop-filter: blur(10px);
        }

        .form-group input::placeholder,
        .form-group textarea::placeholder {
            color: rgba(255,255,255,0.6);
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #00f5ff;
            box-shadow: 0 0 20px rgba(0, 245, 255, 0.3);
            transform: scale(1.02);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 120px;
        }

        .submit-btn {
            width: 100%;
            padding: 1.2rem;
            background: linear-gradient(45deg, #00f5ff, #ff00ff);
            border: none;
            border-radius: 15px;
            color: white;
            font-size: 1.1rem;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 2px;
            position: relative;
            overflow: hidden;
        }

        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(0, 245, 255, 0.4);
        }

        .submit-btn:active {
            transform: translateY(-1px);
        }

        /* Particules */
        .particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
        }

        .particle {
            position: absolute;
            background: linear-gradient(45deg, #00f5ff, #ff00ff);
            border-radius: 50%;
            animation: float 6s infinite linear;
        }

        @keyframes float {
            0% {
                transform: translateY(100vh) rotate(0deg);
                opacity: 1;
            }
            100% {
                transform: translateY(-100px) rotate(360deg);
                opacity: 0;
            }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .title {
                font-size: 4rem;
            }
            
            .logo {
                font-size: 1.8rem;
            }
            
            .form-container {
                padding: 2rem;
                margin: 1rem;
            }
        }

        /* Scroll indicator */
        .scroll-indicator {
            position: fixed;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%);
            width: 40px;
            height: 40px;
            background: rgba(0,255,255,0.3);
            border-radius: 50%;
            animation: bounce 2s infinite;
            z-index: 1000;
            cursor: pointer;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateX(-50%) translateY(0); }
            40% { transform: translateX(-50%) translateY(-10px); }
            60% { transform: translateX(-50%) translateY(-5px); }
        }
    </style>
</head>
<body>
    <!-- Particules de fond -->
    <div class="particles" id="particles"></div>

    <!-- Header -->
    <header>
        <nav>
            <div class="logo">blanc.iut</div>
        </nav>
    </header>

    <!-- Contenu principal -->
    <div class="main">
        <h1 class="title">blanc.iut</h1>
        <p class="subtitle">Contactez-nous</p>
        
        <form class="form-container" onsubmit="return submitForm(event)">
            <div class="form-group">
                <input type="text" placeholder="Nom" required>
            </div>
            <div class="form-group">
                <input type="email" placeholder="Email" required>
            </div>
            <div class="form-group">
                <input type="text" placeholder="Sujet" required>
            </div>
            <div class="form-group">
                <textarea placeholder="Message" required></textarea>
            </div>
            <button type="submit" class="submit-btn">Envoyer</button>
        </form>
    </div>

    <!-- Indicateur de scroll -->
    <div class="scroll-indicator"></div>

    <script>
        // Création des particules
        function createParticles() {
            const particlesContainer = document.getElementById('particles');
            for (let i = 0; i < 50; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                particle.style.left = Math.random() * 100 + '%';
                particle.style.width = particle.style.height = (Math.random() * 6 + 2) + 'px';
                particle.style.animationDelay = Math.random() * 6 + 's';
                particle.style.animationDuration = (Math.random() * 3 + 4) + 's';
                particlesContainer.appendChild(particle);
            }
        }

        // Formulaire bidon
        function submitForm(event) {
            event.preventDefault();
            
            // Animation de succès
            const btn = event.target.querySelector('.submit-btn');
            const originalText = btn.innerText;
            
            btn.innerText = 'Envoyé !';
            btn.style.background = 'linear-gradient(45deg, #00ff88, #00cc66)';
            
            setTimeout(() => {
                btn.innerText = originalText;
                btn.style.background = 'linear-gradient(45deg, #00f5ff, #ff00ff)';
                event.target.reset();
            }, 2000);
            
            return false;
        }

        // Initialisation
        window.addEventListener('load', () => {
            createParticles();
        });

        // Effet sur le scroll indicator
        document.querySelector('.scroll-indicator').addEventListener('click', () => {
            window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
        });
    </script>
</body>
</html>
