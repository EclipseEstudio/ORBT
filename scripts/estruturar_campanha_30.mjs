// Autoria reproduzível das fases novas e fragmentação das rochas antigas.
import fs from 'node:fs';
const pasta = 'Recursos/Fases/';
const ler = nome => JSON.parse(fs.readFileSync(pasta + nome + '.json', 'utf8'));
const escrever = (nome, dados) => fs.writeFileSync(pasta + nome + '.json', JSON.stringify(dados, null, 2) + '\n');
const catalogo = JSON.parse(fs.readFileSync('Recursos/Niveis.json', 'utf8'));
function corpo(id, type, position, radius, extras = {}) {
  return {id, type, position, mass: 0, visual_radius: radius, collision_radius: radius,
    capture_radius: ['station', 'planet', 'earth'].includes(type) ? radius : 0,
    danger_radius: type === 'asteroid' || type === 'sun' ? radius : 0,
    proximity_radius: radius + 25, ...extras};
}
function par(a, b, pa, pb, saida = 0) {
  return [corpo(a, 'portal', pa, 16, {target_id:b, exit_degrees:180}),
    corpo(b, 'portal', pb, 16, {target_id:a, exit_degrees:saida})];
}
function base(id, name, order, fuel, oxygen, goal, extras, tutorial, nebula = false) {
  const f = {schema_version:1, content_version:1, id, name, order,
    bounds:{position:[-180,-320],size:[goal[0]+400,880]}, initial_fuel:fuel, flight_timeout:oxygen,
    physics:{gravity_constant:1,softening:8}, ship:{radius:6,mass:1,dead_zone:10,max_drag:80,max_impulse:100},
    start:{body_id:'estacao_partida',angle_degrees:0},
    goal:corpo('terra','earth',goal,24,{mass:180000,gravity_radius:62}),
    bodies:[corpo('estacao_partida','station',[-20,0],14),...extras],
    camera:{zoom:0.65,overview:{position:[-80,-220],size:[goal[0]+160,700]}}, tutorial,
    notes:'Campanha de 30 fases. Três douradas por fase; azuis opcionais. Chegar à Terra confirma as coletas.',stars:[]};
  if (nebula) f.nebula = {visibility_radius: typeof nebula === 'number' ? nebula : 110};
  return f;
}
const novas = [];
novas.push(base('fenda_no_espaco','Fenda no Espaço',21,3,25,[800,0],par('A','B',[120,0],[640,0]),
  'Entre no anel A para sair em B. O salto é instantâneo, preserva a rapidez e não consome combustível. A seta do anel indica a direção de saída.'));
novas.push(base('salto_entre_rochas','Salto entre Rochas',22,3,25,[850,0],
  [...par('A','B',[130,0],[650,0]),...Array.from({length:18},(_,i)=>corpo('cinturao_'+i,'asteroid',[380, -220+i*26],10))],
  'O cinturão bloqueia a passagem direta. Use A para atravessar e sair em B. Planeje a saída antes de lançar.'));
novas.push(base('nevoa_cega','Névoa Cega',23,4,25,[540,0],[],
  'A nebulosa esconde tudo fora do alcance circular da nave, inclusive no mapa. A bússola aponta para a Terra; os instrumentos indicam tanques e portais.',125));
// Reutiliza a geometria de gravidade já validada, mas com visão limitada.
const curva = ler('curva_gravitacional');
for (const [id,name,order,fuel,radius,rotation] of [
  ['rota_no_escuro','Rota no Escuro',24,4,110,0],
  ['orbita_cega','Órbita Cega',27,4,85,28]
]) {
  const f = structuredClone(curva);
  Object.assign(f,{id,name,order,content_version:1,initial_fuel:fuel,flight_timeout:25,nebula:{visibility_radius:radius}});
  const planeta = f.bodies.find(b=>b.type==='planet');
  if(rotation) planeta.rotation={degrees_per_second:rotation}; else delete planeta.rotation;
  f.tutorial = rotation ? 'A gravidade e a rotação continuam ativas na névoa. Pousar interrompe o gasto de oxigênio; espere o giro para escolher a saída.' :
    'Há um planeta oculto na rota. Observe a direção e a velocidade da nave: a gravidade continua atuando fora do campo de visão.';
  novas.push(f);
}
novas.push(base('desvio_nebuloso','Desvio Nebuloso',25,3,20,[-80,100],[
  corpo('apoio_1','station',[180,-140],23),
  corpo('apoio_3','station',[250,30],21),
  ...[0,1,2,3,4,5,6].map(i=>corpo('barreira_'+i,'asteroid',[350,-50+i*24],9)),
  ...[30,50].map((y,i)=>corpo('atalho_'+i,'asteroid',[-50,y],8))],
  'Três cargas não bastam para a rota de escalas. Desvie até o tanque (+1), guiado pelo instrumento, e conserve carga para decolar.',95));
novas.push(base('portal_invisivel','Portal Invisível',26,3,20,[850,70],
  par('A','B',[150,-90],[650,70]),
  'O portal está escondido na névoa. Use o rumo e a distância do instrumento para encontrar A; depois siga a bússola da Terra.',90));
novas.push(base('rede_de_portais','Rede de Portais',28,4,25,[1050,0],[
  ...par('A','B',[120,0],[370,-120]),...par('C','D',[550,-120],[820,0]),
  corpo('sol','sun',[900,120],26,{mass:180000,gravity_radius:190}),
  ...Array.from({length:10},(_,i)=>corpo('rocha_'+i,'asteroid',[260,-100+i*24],9))],
  'Use dois pares de portais: A–B e C–D. Após o segundo salto, compense a atração solar. Há um tanque +1 para uma correção extra.'));
novas.push(base('travessia_extrema','Travessia Extrema',29,4,20,[980,180],[
  corpo('apoio_1','station',[160,-120],23),...par('A','B',[330,-120],[650,60],90),
  corpo('apoio_2','station',[650,180],23),corpo('apoio_3','station',[810,-100],22),
  corpo('movel','asteroid',[500,120],10,{orbit:{center:[500,180],period_seconds:18,clockwise:true}}),
  ...Array.from({length:18},(_,i)=>corpo('cinturao_'+i,'asteroid',[500,-220+i*25],9))],
  'Combine os instrumentos, o salto e as escalas. O tanque fora da rota fornece a quinta carga. Uma rocha orbital exige observar a aproximação.',85));
novas.push(base('grande_retorno','O Grande Retorno',30,5,25,[1420,200],[
  corpo('planeta','planet',[180,0],25,{mass:55000,gravity_radius:100,rotation:{degrees_per_second:24}}),
  ...par('A','B',[180,-160],[470,0]),
  corpo('orbital','station',[660,-18],24,{orbit:{center:[660,0],period_seconds:22,clockwise:true}}),
  ...par('C','D',[870,40],[1030,200]),
  corpo('apoio_3','station',[1180,200],22),corpo('apoio_4','station',[1040,20],21),
  ...Array.from({length:12},(_,i)=>corpo('cinturao_'+i,'asteroid',[960,-140+i*26],9))],
  'Use o giro do planeta, os portais e a estação móvel. Desvie para o tanque +1: as seis decolagens exigem todas as cargas. A Terra espera além da névoa.',85));

for(const f of (process.argv.includes('--somente-obstaculos') ? [] : novas)) {
  if([25,28,29,30].includes(f.order)) f.fuel_pickups=[{id:'tanque_1',position:({25:[-20,-280],28:[897,-100],29:[35,-220],30:[530,-130]})[f.order],radius:9,amount:1}];
  if(f.order===25) {f.bounds={position:[-220,-400],size:[1000,1000]};f.camera.overview={position:[-180,-340],size:[760,780]};}
  // A ferramenta de simulação posiciona as estrelas em rotas verificadas.
  escrever(f.id,f); catalogo[f.id]='res://'+pasta+f.id+'.json';
}
for(const arquivo of fs.readdirSync(pasta).filter(nome=>nome.endsWith('.json'))) {
  const nome=arquivo.replace('.json',''); const f=ler(nome);
  let mudou=false; const corpos=[];
  for(const b of f.bodies) {
    if(b.type!=='asteroid' || b.visual_radius<=14) {corpos.push(b);continue;}
    mudou=true; const R=b.visual_radius, r=Math.min(9,R/3), passo=r*1.65; let indice=0;
    for(let y=-Math.floor((R-r)/passo);y<=Math.floor((R-r)/passo);y++) {
      for(let x=-Math.ceil(R/passo);x<=Math.ceil(R/passo);x++) {
        const dx=x*passo+(Math.abs(y)%2)*passo/2, dy=y*passo*Math.sqrt(3)/2;
        if(Math.hypot(dx,dy)+r>R)continue;
        const pedra=corpo(indice===0?b.id:b.id+'_'+indice,'asteroid',[b.position[0]+dx,b.position[1]+dy],r);
        if(b.orbit) pedra.orbit=structuredClone(b.orbit);
        corpos.push(pedra);indice++;
      }
    }
    if(!indice)corpos.push(corpo(b.id,'asteroid',b.position,Math.min(12,R)));
  }
  f.bodies=corpos;
  if(mudou)f.content_version++;
  if(catalogo[f.id]) {
    f.notes='Campanha: 3 níveis de 10 fases. Nível 2 exige 30 douradas; nível 3 exige 60 acumuladas. Cada dezena deve estar completa. Azuis opcionais. Coletas confirmadas ao chegar à Terra.';
    if(f.order===2)f.tutorial='Ajuste direção e força. A estrela azul é opcional; as douradas abrem o próximo nível. Chegue à Terra para confirmar as coletas.';
    if(f.order===12)f.tutorial='Observe a órbita da estação de partida. O movimento muda a posição e a velocidade de saída; espere a janela antes de lançar.';
  }
  escrever(nome,f);
}
fs.writeFileSync('Recursos/Niveis.json',JSON.stringify(catalogo,null,2)+'\n');
console.log('Campanha estruturada: '+Object.keys(catalogo).length+' fases.');
