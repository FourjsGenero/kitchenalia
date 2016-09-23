// This function is called by the Genero Client Container
// so the web component can initialize itself and initialize
// the gICAPI handlers
var img_nodes=[];
function crEl(tag,clazz,id) { 
  var el=document.createElement(tag); 
  //if (tag=="input") {el.type="search";}
  if(clazz) { el.className=clazz; }
  if(id) { el.id=String(id); } //needs to be String for dojo
  return el;
}
if ( document.addEventListener ) {
  addEv = function ( el, e, f ) { el.addEventListener( e, f, false ) }
} else {
  addEv = function ( el, e, f ) { el.attachEvent( "on" + e, f ) }
}
addEv(document,"click",handleClick);

function getEvTarget(event) {
  if (!event) {
    return undefined;
  }
  if(event.REPLAYTARGET) { return event.REPLAYTARGET; }
  return event.target ? 
    ((event.target.nodeType==3)?event.target.parentElement:event.target)
    : event.srcElement;
}

function handleClick(ev) {
  var target = getEvTarget(ev);
  if(target.tagName=="IMG") {
    //alert("clicked on "+target.tagName+",src="+target.src+",index:"+target.DATAINDEX);
    gICAPI.SetData(target.DATAINDEX);
    gICAPI.Action("click");
  }
  return true;
}

function setImages(images) {
  //console.log("onData:"+images);
  alert("1");
  for (var i in img_nodes) {
    var old_img=img_nodes[i];
    document.body.removeChild(old_img);
  }
    alert("2");
  img_nodes=[];
    alert("3");
  var img_arr=JSON.parse(images);
    alert("4");
  for (var j in img_arr) {
    var img=crEl("img");
    img.src=img_arr[j];
    //console.log("img:"+j+",img:"+img.src);
    img.DATAINDEX=j;
    document.body.appendChild(img);
    img_nodes[j]=img;
  }
}

onICHostReady = function(version) {
   //console.log("onICHostReady");
   if ( version != 1.0 ) {
      alert('Invalid API version');
      return;
   }

   // Initialize the focus handler called by the Genero Client
   // Container when the DVM set/remove the focus to/from the
   // component
   gICAPI.onFocus = function(polarity) {
      /* looks bad on IOS, we need to add a possibility to know the client
      if ( polarity ) {
         document.body.style.border = '1px solid blue';
      } else {
         document.body.style.border = '1px solid grey';
      }
      */
   }
   gICAPI.onData = function(images) {
     //setImages(images);
   }

   gICAPI.onProperty = function(p) {
     var myObject = eval('(' + p + ')');
     setImages(myObject.imglist);
   }

   set_images = function(p) {
   alert("10");
     alert(p);
     var myObject = eval('(' + p + ')');
     alert(myObject);
     alert("20");
     //setImages(myObject.imglist);
     setImages(myObject);
   }
}

