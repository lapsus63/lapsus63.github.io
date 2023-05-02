# Javascript Snippets

### Angular setup dev from existing project

<p>Setup script to RAZ current system installation to required project angular version and dependancies</p>
<p><b>Prerequisites:</b>  install correct version of npm.</p>
<p>
<details>
  <summary>Show bash script</summary>

```bash
NOW=$(date +'%Y%m%d%H%M%S')
NPM_FILE=${HOME}/.npmrc

# backup existing before overwrite
[ -f "${HOME}/.npmrc" ] && cp ${HOME}/.npmrc ${HOME}/.npmrc_bak${NOW}
[ -d "${HOME}/AppData/Roaming/npm" ] && mv ${HOME}/AppData/Roaming/npm ${HOME}/AppData/Roaming/npm_bak${NOW}
[ -d "${HOME}/AppData/Roaming/npm-cache" ] && mv ${HOME}/AppData/Roaming/npm ${HOME}/AppData/Roaming/npm-cache_bak${NOW}

cat <<EOF > ${NPM_FILE}
strict-ssl=false
EOF

# init angular and node modules
rm -rf node_modules package-lock.json
npm install --save-dev
npm install --save-dev @angular-devkit/build-angular
./node_modules/.bin/ng version
  
# Start project: ./node_modules/.bin/ng serve
```
</details>
</p>

### sigma.js graphs

<p>
<details>
  <summary>Show file index.html</summary>

```html
<script src="./lib/sigma/sigma.min.js"></script>
<script src="./lib/sigma/plugins/sigma.parsers.gexf/gexf-parser.js"></script>
<script src="./lib/sigma/plugins/sigma.parsers.gexf/sigma.parsers.gexf.js"></script>
<script src="./lib/sigma/plugins/sigma.parsers.json/sigma.parsers.json.js"></script>
<!-- for layouts -->
<script src="./lib/sigma/plugins/sigma.plugins.animate/sigma.plugins.animate.js"></script>
<!-- No Overlap -->
<script src="./lib/sigma/plugins/sigma.layout.noverlap/sigma.layout.noverlap.js"></script>
<!-- Force Atlas -->
<script src="./lib/sigma/plugins/sigma.layout.forceAtlas2/worker.js"></script>
<script src="./lib/sigma/plugins/sigma.layout.forceAtlas2/supervisor.js"></script>
<!-- Custom node shapes/images -->
<script src="./lib/sigma/plugins/sigma.renderers.customShapes/shape-library.js"></script>
<script src="./lib/sigma/plugins/sigma.renderers.customShapes/sigma.renderers.customShapes.js"></script>
<script src="./lib/sigma/image-renderer.js"></script>

<!-- -->

<div id='sigma-container'></div>

<!-- -->

<script>

      // Initialize sigma:
      var s = new sigma(
        {
           renderer: {
             container: document.getElementById('sigma-container'),
             type: 'canvas'
           },
           settings: {
            labelThreshold : 0 /* always display labels */
           }
         }
       );
       
       /*
        * Custom variables
        */
        var targets = [];
       
       /*
        * Listeners
        */
        
        function hideChildrenPath(node) {
            if (!node) {
                return;
            }
            node.hidden = true;
            s.graph.edges().forEach((edge) => {
                if (edge.source == node.id) {
                    hideChildrenPath(getNodeById(edge.target));
                }
            });
            
        }
        
        function getNodeById(id) {
            return s.graph.nodes().filter(n => n.id == id)[0];
        }

       s.bind('overNode outNode clickNode doubleClickNode rightClickNode', function(e) {
        // console.log(e.type, e.data.node.label, e.data.captor);
      });
      s.bind('overNode', function(e) {
        document.getElementById('sigma-container').style.cursor = 'pointer';
      });
      s.bind('outNode', function(e) {
        document.getElementById('sigma-container').style.cursor = 'default';
      });
      s.bind('clickNode', function(e) {
        // console.log(e, targets, e.data.node.href);
        
        s.graph.edges().forEach((edge) => {
            if (edge.source == e.data.node.id) {
               var t = edge.target;
               s.graph.nodes().forEach((node) => {
                if (node.id == t) {
                    if (node.hidden) {
                        node.hidden = false;
                    } else {
                        hideChildrenPath(node);
                    }
                    // console.log('Visibility changed : ', node);
                }
               });
            }
        });
        if (e.data.node.href) {
            // window.open(e.data.node.href, e.data.node.label);
            document.getElementById("doc-container").src = e.data.node.href;
        } else {
            s.refresh();
            // s.startNoverlap();
            // s.startForceAtlas2({worker: true, barnesHutOptimize: false});
        }
      });
      
      /*
       * Noverlap layout configuration
       */
        var noverlapListener = s.configNoverlap({
          nodeMargin: 0.1,
          scaleNodes: 1.05,
          gridSize: 75,
          easing: 'quadraticInOut', // animation transition function
          duration: 5000   // animation duration. Long here for the purposes of this example only
        });
        // Bind the events:
        noverlapListener.bind('start stop interpolate', function(e) {
          if(e.type === 'start') {
            console.time('noverlap');
          }
          if(e.type === 'interpolate') {
            console.timeEnd('noverlap');
          }
        });
        
       //sigma.parsers.gexf('./index.gexf', s);
       sigma.parsers.json('./index.json', s,
          function() {
            /*
             * Graph initialisation
             */
            // console.log(s.graph);
            
            s.graph.nodes().forEach((node, i, a) => {
                node.x = Math.cos(Math.PI * 2 * i / a.length);
                node.y = Math.sin(Math.PI * 2 * i / a.length);
                node.size= 1;
                
                // console.log(node, node.p);
                if (node.p) {
                    if (node.p != 'root') {
                        node.hidden = true;
                    }
                    s.graph.nodes().forEach((node2, i, a) => {
                        if (node2.id == node.p) {
                        s.graph.addEdge({
                            id: node2.id + '_' + node.id,
                            source: node2.id,
                            target: node.id,
                            type: 'goo'
                        
                        });
                        }
                    });
                }
                
                if (node.icon) {
                    node.type = 'image';
                    if (node.icon == 'server') {
                        node.icon = 'https://cdn0.iconfinder.com/data/icons/30-hardware-line-icons/64/Server-128.png';
                    }
                    node.iconFactor = 2;
                } else if (node.href) {
                    node.type = 'image';
                    node.icon = 'https://cdn4.iconfinder.com/data/icons/buno-info-signs/32/__link_chain_connection-128.png';
                    node.iconFactor = 1;
                    node.color='#00f';
                    node.labelColor='#00f'; /* not implemented */
                } else {
                    node.color='#f00';
                }
            });
            
            CustomShapes.init(s);
            s.refresh();
            // Noverlap
            // s.startNoverlap();
            /* ratio: margin between nodes and canvas borders */
            s.cameras[0].goTo({ x: 0, y: 0, angle: 0, ratio: 1.1 });
            // Force Atlas2
            s.startForceAtlas2({worker: true, barnesHutOptimize: false});
            
          }
        )
        
    </script>

```
  </details>
  </p>
