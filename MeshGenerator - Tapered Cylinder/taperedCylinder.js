var taperedCylinder = function(armLength, baseRadius, endRadius, numStacks, numSlices){
  this.armLength = armLength;
  this.baseRadius = baseRadius;
  this.endRadius = endRadius;
  this.numStacks = numStacks;
  this.numSlices = numSlices;

  this.stackDistance = armLength/(numSlices+1);

  this.generateMesh = function(){
    var mesh = [];
    var yzAngle = 0.0;
    var x = -1.00;
    var radius = baseRadius;
    var interRadius = (baseRadius-endRadius)/(numStacks); //interpolation between radius
    var stackVertices = create2DArray(this.numStacks);
    var vertexCount = 0;

    for(var i = 0; i<this.numStacks; i++){            //stack number
      for(var j = 0; j<this.numSlices; j++){          // creates vertices for one stack
        mesh.push(x);                                 //push x value
        mesh.push(radius*Math.sin(radians(yzAngle))); //push y value
        mesh.push(radius*Math.cos(radians(yzAngle))); //push z value
        yzAngle += 360 /this.numSlices;
        stackVertices[i][j] = vertexCount;
        vertexCount++;
      }
      radius -= interRadius;
      x += this.stackDistance;
    }
    this.stackVertices = stackVertices;
    this.mesh = mesh;
  }

  this.generateFaces = function(){
    var triangle1, triangle2;
    var faces = [];
    for(var s = 0; s<this.numStacks; s++){            //slice number
      for(var t =0; t<this.numSlices; t++){
          if(s<this.numStacks-1 && t== this.numSlices-1){
            faces.push(this.stackVertices[s][t]);     //----first triangle
            faces.push(this.stackVertices[s+1][t]);
            faces.push(this.stackVertices[s+1][0]);
            faces.push(this.stackVertices[s][t]);     //----second triangle
            faces.push(this.stackVertices[s+1][0]);
            faces.push(this.stackVertices[s][0]);
          }
          else if(s<this.numStacks-1){
            faces.push(this.stackVertices[s][t]);     //----first triangle
            faces.push(this.stackVertices[s+1][t]);
            faces.push(this.stackVertices[s+1][t+1]);
            faces.push(this.stackVertices[s][t]);     //----second triangle
            faces.push(this.stackVertices[s+1][t+1]);
            faces.push(this.stackVertices[s][t+1]);
          }
      }
    }
    this.faces = faces;
  }

  function create2DArray(rows){
    var x = [];
    for(var i = 0; i<rows; i++){
      x[i] = [];
    }
    return x;
  }

  function radians(angle){
    var radians = angle*(Math.PI/180);
    return radians;
  }
}
