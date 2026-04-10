#!/bin/bash
FILE="/Volumes/EASYROMS/ports/gamelist.xml"

# --- Translate Names ---

# Batch 1
perl -pi -e 's|<name>指挥官天才</name>|<name>Commander Genius</name>|g' "$FILE"
perl -pi -e 's|<name>水蛇神的迷宫城</name>|<name>Hydra Castle Labyrinth</name>|g' "$FILE"
perl -pi -e 's|<name>怒之铁拳重制版</name>|<name>Streets of Rage Remake</name>|g' "$FILE"
perl -pi -e 's|<name>马拉松-无限</name>|<name>Marathon Infinity</name>|g' "$FILE"
perl -pi -e 's|<name>马拉松2</name>|<name>Marathon 2</name>|g' "$FILE"
perl -pi -e 's|<name>马拉松</name>|<name>Marathon</name>|g' "$FILE"
perl -pi -e 's|<name>急冻恐龙</name>|<name>Dinothawr</name>|g' "$FILE"
perl -pi -e 's|<name>洞窟物语</name>|<name>Cave Story</name>|g' "$FILE"
perl -pi -e 's|<name>洞窟探险</name>|<name>Spelunky</name>|g' "$FILE"
perl -pi -e 's|<name>弹弹跳跳闪避人</name>|<name>VVVVVV</name>|g' "$FILE"
perl -pi -e 's|<name>铲子骑士 - 无主珍宝</name>|<name>Shovel Knight: Treasure Trove</name>|g' "$FILE"
perl -pi -e 's|<name>波比排球2</name>|<name>Blobby Volley 2</name>|g' "$FILE"
perl -pi -e 's|<name>被诅咒的卡斯蒂利亚</name>|<name>Maldita Castilla</name>|g' "$FILE"
perl -pi -e 's|<name>C-型狗</name>|<name>C-Dogs</name>|g' "$FILE"
perl -pi -e 's|<name>蔚蓝</name>|<name>Celeste</name>|g' "$FILE"
perl -pi -e 's|<name>叛逆机械师</name>|<name>Iconoclasts</name>|g' "$FILE"
perl -pi -e 's|<name>钢铁突击</name>|<name>Steel Assault</name>|g' "$FILE"
perl -pi -e 's|<name>猫头鹰男孩</name>|<name>Owlboy</name>|g' "$FILE"
perl -pi -e 's|<name>银河战士 II：萨姆斯归来</name>|<name>Metroid II: Return of Samus</name>|g' "$FILE"
perl -pi -e 's|<name>传说之下</name>|<name>Undertale</name>|g' "$FILE"
perl -pi -e 's|<name>暗黑破坏神</name>|<name>Diablo</name>|g' "$FILE"
perl -pi -e 's|<name>百慕大综合症</name>|<name>Bermuda Syndrome</name>|g' "$FILE"
perl -pi -e 's|<name>刺猬索尼克 CD</name>|<name>Sonic CD</name>|g' "$FILE"
perl -pi -e 's|<name>刺猬索尼克</name>|<name>Sonic the Hedgehog</name>|g' "$FILE"
perl -pi -e 's|<name>刺猬索尼克 2</name>|<name>Sonic the Hedgehog 2</name>|g' "$FILE"
perl -pi -e 's|<name>索尼克机器大战2</name>|<name>Sonic Robo Blast 2</name>|g' "$FILE"
perl -pi -e 's|<name>索尼克机器大战2赛车</name>|<name>Sonic Robo Blast 2 Kart</name>|g' "$FILE"
perl -pi -e 's|<name>虎胆神猫</name>|<name>Captain Claw</name>|g' "$FILE"
perl -pi -e 's|<name>纺时者</name>|<name>Timespinner</name>|g' "$FILE"
perl -pi -e 's|<name>半条命</name>|<name>Half-Life</name>|g' "$FILE"
perl -pi -e 's|<name>超级马里奥64</name>|<name>Super Mario 64</name>|g' "$FILE"
perl -pi -e 's|<name>辐射2</name>|<name>Fallout 2</name>|g' "$FILE"
perl -pi -e 's|<name>重返德军总部</name>|<name>Return to Castle Wolfenstein</name>|g' "$FILE"
perl -pi -e 's|<name>自由星球</name>|<name>Freedom Planet</name>|g' "$FILE"
perl -pi -e 's|<name>雷神之锤  II</name>|<name>Quake II</name>|g' "$FILE"
perl -pi -e 's|<name>雷神之锤  III</name>|<name>Quake III Arena</name>|g' "$FILE"
perl -pi -e 's|<name>雷神之锤</name>|<name>Quake</name>|g' "$FILE"

# Paladin Games
perl -pi -e 's|<name>仙剑奇侠传天啟神佑2.0</name>|<name>Legend of Sword and Fairy: Apocalypse 2.0</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传梦时空3.7</name>|<name>Legend of Sword and Fairy: Dream Time 3.7</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传梦幻月影1.443</name>|<name>Legend of Sword and Fairy: Dream Moon Shadow 1.443</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传梦幻版2.3</name>|<name>Legend of Sword and Fairy: Dream Version 2.3</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传联盟幻妖版</name>|<name>Legend of Sword and Fairy: Alliance Demon Version</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传魂牵梦萦1.67</name>|<name>Legend of Sword and Fairy: Soul Dreams 1.67</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑奇侠传95魔改加强版</name>|<name>Legend of Sword and Fairy: 95 Mod Enhanced</name>|g' "$FILE"
perl -pi -e 's|<name>仙剑98柔情篇</name>|<name>Legend of Sword and Fairy: 98 Tender Edition</name>|g' "$FILE"

# --- Translate Descriptions ---

perl -0777 -pi -e 's|(<name>Commander Genius</name>\s*<desc>).*?(</desc>)|$1¿Quizás fue la historia lo que nos atrajo? Es un niño, como nosotros entonces, con un coeficiente intelectual al límite y una identidad secreta genial. Barry Blaze, estudiante normal de día, Comandante Keen, superhéroe intergaláctico de noche. En la primera historia, Billy queda atrapado en Marte y debe recuperar piezas de su nave para salvar la Tierra. ¿Apasionante, verdad? Bueno, añade algo al juego.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Hydra Castle Labyrinth</name>\s*<desc>).*?(</desc>)|$1Hydra Castle Labyrinth, originalmente Meikyuujou Hydra, es un juego de plataformas indie gratuito de E. Hashimoto (Buster). El juego recuerda a los clásicos Metroidvania como Knightmare II: exploras una enorme mazmorra laberíntica, recogiendo herramientas y llaves para avanzar.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Streets of Rage Remake</name>\s*<desc>).*?(</desc>)|$1Jugadores españoles han enriquecido enormemente el clásico juego de MD Streets of Rage, añadiendo muchos mapas y nuevos personajes. Vale la pena jugarlo.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Marathon Infinity</name>\s*<desc>).*?(</desc>)|$1Marathon Infinity es la tercera entrega de la trilogía de acción y ciencia ficción en primera persona creada originalmente por Bungie para Mac OS. Marathon (1994), Marathon 2 (1995) y Marathon Infinity (1996) son ampliamente considerados los precursores de Halo.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Marathon 2</name>\s*<desc>).*?(</desc>)|$1La segunda parte de Marathon, ambientada en 2794 en una gran nave colonia multigeneracional llamada UESC Marathon. La trama te pone como oficial de seguridad luchando contra una invasión alienígena hostil alrededor de Tau Ceti.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Marathon</name>\s*<desc>).*?(</desc>)|$1Ambientado en 2794 en la nave colonia UESC Marathon. La nave fue convertida a partir de Deimos, una de las lunas de Marte. La trama gira en torno a una invasión alienígena y tú eres un oficial de seguridad que debe detenerla.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Dinothawr</name>\s*<desc>).*?(</desc>)|$1Dinothawr es un juego de rompecabezas donde un pequeño dinosaurio necesita empujar a sus compañeros congelados hacia el fuego para derretir el hielo y salvarlos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Cave Story</name>\s*<desc>).*?(</desc>)|$1Cave Story te lleva a un mundo raro donde los Mimiga, criaturas inocentes parecidas a conejos, corren libres. Despiertas en una cueva oscura sin memoria. Descubre el peligro que acecha a los Mimiga a manos de un científico loco y salva el día.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Spelunky</name>\s*<desc>).*?(</desc>)|$1Spelunky es un juego de acción donde el protagonista es un aventurero con sombrero y látigo que busca tesoros por todas partes.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>VVVVVV</name>\s*<desc>).*?(</desc>)|$1VVVVVV es un juego de plataformas de alta dificultad con estilo clásico y extraño. Eres el capitán de una nave espacial atrapado con tu tripulación en una dimensión extraña. Debes liderar y explorar este mundo mágico usando la teletransportación y el control de la gravedad.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Shovel Knight: Treasure Trove</name>\s*<desc>).*?(</desc>)|$1Shovel Knight: Treasure Trove es la edición completa de Shovel Knight, una serie de juegos de acción y aventura clásica con estética de 8 bits. Juega como Shovel Knight, corre, salta y lucha para encontrar a tu amada perdida y derrotar a la Hechicera.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Blobby Volley 2</name>\s*<desc>).*?(</desc>)|$1Un relajante juego de voleibol de playa.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Maldita Castilla</name>\s*<desc>).*?(</desc>)|$1Maldita Castilla (Cursed Castilla) es un juego de acción arcade desarrollado por Locomalito. Basado en la mitología española y europea, rinde homenaje a Ghosts'\''n Goblins.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>C-Dogs</name>\s*<desc>).*?(</desc>)|$1C-Dogs SDL es un port del viejo juego de arcade de DOS C-Dogs para sistemas operativos modernos. Es un juego de disparos donde puedes jugar solo o cooperativo para completar misiones.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Apocalypse 2.0</name>\s*<desc>).*?(</desc>)|$1Legend of Sword and Fairy: Apocalypse God'\''s Blessing 2.0$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Dream Time 3.7</name>\s*<desc>).*?(</desc>)|$1Juego fan de Legend of Sword and Fairy hecho por un gran fan.$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Dream Moon Shadow 1.443</name>\s*<desc>).*?(</desc>)|$1Versión mejorada basada en la versión Dream 1.0, con dificultad aumentada para mayor entretenimiento.$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Dream Version 2.3</name>\s*<desc>).*?(</desc>)|$1Versión fan basada en el DOS Paladin original con modificaciones en la trama para lograr un final perfecto.$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Alliance Demon Version</name>\s*<desc>).*?(</desc>)|$1Continuación de Zu An Paladin, simple y brutal, pero muy divertido.$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: Soul Dreams 1.67</name>\s*<desc>).*?(</desc>)|$1Legend of Sword and Fairy: Soul Dreams 1.67$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: 95 Mod Enhanced</name>\s*<desc>).*?(</desc>)|$1Versión 95 modificada, basada en la versión original de DOS.$2|gs' "$FILE"
perl -0777 -pi -e 's|(<name>Legend of Sword and Fairy: 98 Tender Edition</name>\s*<desc>).*?(</desc>)|$1Legend of Sword and Fairy 98 Tender Edition, la versión simplificada de Windows 95 lanzada por Softstar.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Celeste</name>\s*<desc>).*?(</desc>)|$1Celeste es una obra maestra de los creadores de TowerFall. Un juego de plataformas de ritmo rápido donde ayudas a Madeline a superar sus demonios internos mientras escala la montaña Celeste. Supera cientos de desafíos y descubre secretos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Iconoclasts</name>\s*<desc>).*?(</desc>)|$1Únete a la mecánica rebelde Robin para descubrir los secretos de un planeta moribundo. Un magnífico juego de plataformas y acción lleno de rompecabezas, personajes interesantes y jefes desafiantes.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Steel Assault</name>\s*<desc>).*?(</desc>)|$1¡Este juego de acción de estilo retro te lleva a una América post-apocalíptica! Usa puñetazos, látigos y tirolinas para sobrevivir. Juega como Taro Takahashi, un soldado en una misión de venganza.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Owlboy</name>\s*<desc>).*?(</desc>)|$1Owlboy es un juego de aventuras y plataformas impulsado por la historia. ¡Vuela y explora un nuevo mundo en las nubes! Invita a tus amigos a explorar los cielos abiertos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Metroid II: Return of Samus</name>\s*<desc>).*?(</desc>)|$1AM2R es un remake mejorado del juego de Game Boy Metroid II: Return of Samus. Sigue a Samus Aran para erradicar los Metroids de su planeta natal SR388. El remake añade mapas, nuevas áreas, gráficos rehechos y una IA mejorada.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Undertale</name>\s*<desc>).*?(</desc>)|$1Undertale es un juego de rol donde controlas a un humano que cae en un mundo subterráneo de monstruos. Debes encontrar la salida o decidir quedarte.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Diablo</name>\s*<desc>).*?(</desc>)|$1Hace mucho tiempo, una guerra secreta entre el Cielo y el Infierno... Diablo, el Señor del Terror, ha sido despertado en las profundidades de la iglesia de Tristram. Elige tu clase (Guerrero, Pícaro o Hechicero) y desciende a las mazmorras para derrotar al mal.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Bermuda Syndrome</name>\s*<desc>).*?(</desc>)|$1Como piloto en la Segunda Guerra Mundial, eres derribado y aterrizas en una isla desconocida que parece estar en la era Jurásica, llena de dinosaurios y monstruos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Sonic CD</name>\s*<desc>).*?(</desc>)|$1Un juego clásico de Sonic. El Dr. Robotnik ha tomado el Little Planet. Sonic debe viajar a través del tiempo, recogiendo Time Stones para detenerlo y salvar a Amy.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Sonic the Hedgehog</name>\s*<desc>).*?(</desc>)|$1El primer juego de Sonic. Un juego de plataformas de velocidad donde Sonic corre a través de niveles para liberar a sus amigos animales de los robots del Dr. Robotnik.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Sonic the Hedgehog 2</name>\s*<desc>).*?(</desc>)|$1Secuela de Sonic the Hedgehog. Sonic y Tails corren a través de varias zonas para derrotar a Robotnik. Introduce el Spin Dash y el modo cooperativo.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Sonic Robo Blast 2</name>\s*<desc>).*?(</desc>)|$1El equipo de fans Sonic Team Junior lanzó una nueva versión del juego fan Sonic Robo Blast 2.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Sonic Robo Blast 2 Kart</name>\s*<desc>).*?(</desc>)|$1Juego de karts estilo retro basado en Sonic Robo Blast 2, con pistas hermosas y objetos locos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Captain Claw</name>\s*<desc>).*?(</desc>)|$1Captain Claw es un juego que combina leyendas de piratas con la tradicional disputa entre gatos y perros, creando personajes y tramas vívidas.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Timespinner</name>\s*<desc>).*?(</desc>)|$1Timespinner es un hermoso juego Metroidvania 2D pixelado. Una joven viaja en el tiempo para destruir el imperio que mató a su familia.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Half-Life</name>\s*<desc>).*?(</desc>)|$1Half-Life es un juego de disparos en primera persona de ciencia ficción de Valve. El juego revolucionó el género con su narrativa inmersiva y jugabilidad.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Super Mario 64</name>\s*<desc>).*?(</desc>)|$1Super Mario 64 es el primer juego de Mario en 3D, lanzado para Nintendo 64. Mario debe rescatar a la Princesa Peach explorando el castillo y saltando a través de pinturas a mundos mágicos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Fallout 2</name>\s*<desc>).*?(</desc>)|$1Fallout 2 es un juego de rol post-apocalíptico. Con un motor mejorado, ofrece más historias, humor negro y libertad que su predecesor.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Return to Castle Wolfenstein</name>\s*<desc>).*?(</desc>)|$1Ambientado en la Segunda Guerra Mundial, juegas como B.J. Blazkowicz, un comando aliado que lucha contra los nazis y sus experimentos ocultos.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Freedom Planet</name>\s*<desc>).*?(</desc>)|$1Freedom Planet es un juego de plataformas de acción retro. Juega como Lilac, Carol o Milla para salvar su mundo de una invasión alienígena.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Quake II</name>\s*<desc>).*?(</desc>)|$1Secuela de Quake. La humanidad contraataca a los Strogg, una raza alienígena cibernética. Debes infiltrarte en su planeta y destruir a su líder.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Quake III Arena</name>\s*<desc>).*?(</desc>)|$1Quake III Arena es un juego de disparos en arena multijugador centrado en la acción rápida y gráficos impresionantes para su época.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>Quake</name>\s*<desc>).*?(</desc>)|$1En Quake, juegas como Ranger, enviado a través de un portal para detener a un enemigo con nombre en código Quake. Un FPS clásico con atmósfera lovecraftiana.$2|gs' "$FILE"

perl -0777 -pi -e 's|(<name>StardewValley</name>\s*<desc>).*?(</desc>)|$1Stardew Valley es un RPG de vida en la granja. Heredas la vieja granja de tu abuelo y debes aprender a vivir de la tierra, cultivar, pescar y hacer amigos en el pueblo.$2|gs' "$FILE"
