import controlP5.*;
import javax.swing.JFileChooser;
import java.io.File;
import gifAnimation.*;

PImage spriteSheet;
PImage[] frames;

int spriteCols = 6;
int spriteRows = 3;
int totalFrames;
int currentFrame = 0;
int spriteWidth, spriteHeight;

ControlP5 cp5;
boolean negativeMode = true;

float frameSpeed = 3;
float threshold = 0;
float charSize = 20;
float brightnessAdjust = 10;
float contrastAdjust = 2;
color asciiColor = color(0, 255, 0);

PFont mono;

int asciiCols = 80;
int asciiRows = 40;

String letters = "01#:=*-. ";

File exportFolder = null;
File lastFolder = null;

GifMaker gif;

void setup() {
  size(800, 800);
  mono = createFont("Courier", int(charSize));
  textFont(mono);
  cp5 = new ControlP5(this);

  // Initialize all ControlP5 elements and set their default values
  cp5.addToggle("negativeMode").setPosition(20, 20).setSize(50, 20).setValue(negativeMode);
  cp5.addSlider("frameSpeed").setPosition(20, 60).setRange(1, 30).setValue(frameSpeed);
  cp5.addSlider("threshold").setPosition(20, 100).setRange(0, 255).setValue(threshold);
  cp5.addSlider("charSize").setPosition(20, 140).setRange(4, 32).setValue(charSize);
  cp5.addSlider("brightnessAdjust").setPosition(20, 180).setRange(-128, 128).setValue(brightnessAdjust);
  cp5.addSlider("contrastAdjust").setPosition(20, 220).setRange(0.5, 3).setValue(contrastAdjust);
  cp5.addSlider("spriteCols").setPosition(20, 260).setRange(1, 20).setValue(spriteCols);
  cp5.addSlider("spriteRows").setPosition(20, 300).setRange(1, 20).setValue(spriteRows);
  cp5.addColorPicker("asciiColorPicker").setPosition(20, 500).setColorValue(asciiColor).setLabel("Color ASCII");

  cp5.addButton("startExport").setLabel("Exportar Sprites").setPosition(20, 340).setSize(120, 20);
  cp5.addButton("startAsciiExport").setLabel("Exportar ASCII").setPosition(20, 380).setSize(120, 20);
  cp5.addButton("startGifExport").setLabel("Exportar GIF").setPosition(20, 420).setSize(120, 20);
  cp5.addButton("selectSpriteSheet").setLabel("Cargar Imagen").setPosition(20, 460).setSize(120, 20);

  // Load and process the initial sprite sheet
  spriteSheet = loadImage("cyberdeck.png");
  regenerateFrames();
}

public void spriteCols(float val) { spriteCols = max(4, int(floor(val))); regenerateFrames(); }
public void spriteRows(float val) { spriteRows = max(2, int(floor(val))); regenerateFrames(); }
public void asciiColorPicker(color c) { asciiColor = c; }

public void startExport() {
  if (frames == null) return;
  exportFolder = selectFolder();
  if (exportFolder == null) return;
  for (int i = 0; i < frames.length; i++) {
    PImage asciiImg = asciiFrame(frames[i]);
    asciiImg.save(exportFolder.getAbsolutePath() + "/frame-" + nf(i, 4) + ".png");
  }
}

public void startAsciiExport() {
  if (frames == null) return;
  exportFolder = selectFolder();
  if (exportFolder == null) return;
  for (int i = 0; i < frames.length; i++) {
    PImage img = frames[i];
    img.loadPixels();
    StringBuilder sb = new StringBuilder();
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int idx = y * img.width + x;
        if (idx >= img.pixels.length) continue;
        float b = brightness(img.pixels[idx]);
        b = (b - 128) * contrastAdjust + 128 + brightnessAdjust;
        b = constrain(b, 0, 255);
        if (threshold > 0) b = (b > threshold) ? 255 : 0;
        if (negativeMode) b = 255 - b;
        sb.append(letters.charAt(int(map(b, 0, 255, 0, letters.length() - 1))));
      }
      sb.append("\n");
    }
    saveStrings(exportFolder.getAbsolutePath() + "/frame-" + nf(i, 4) + ".txt", sb.toString().split("\n"));
  }
}

public void startGifExport() {
  if (frames == null) return;
  
  exportFolder = selectFolder();
  if (exportFolder == null) return;
  
  String gifPath = exportFolder.getAbsolutePath() + "/ascii_animation.gif";
  
  // Crear el GIF
  gif = new GifMaker(this, gifPath, int(1000.0 / frameSpeed));
  
  // Loop infinito
  gif.setRepeat(0); // 0 significa infinito
  
  // Agregar los frames
  for (int i = 0; i < frames.length; i++) {
    gif.addFrame(asciiFrame(frames[i]));
  }
  
  // Terminar exportación
  gif.finish();
}


PImage asciiFrame(PImage img) {
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.background(0);
  pg.textFont(mono);
  pg.textSize(charSize);
  pg.fill(asciiColor);
  float xStep = width / float(img.width);
  float yStep = height / float(img.height);
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int idx = y * img.width + x;
      if (idx >= img.pixels.length) continue;
      float b = brightness(img.pixels[idx]);
      b = (b - 128) * contrastAdjust + 128 + brightnessAdjust;
      b = constrain(b, 0, 255);
      if (threshold > 0) b = (b > threshold) ? 255 : 0;
      if (negativeMode) b = 255 - b;
      pg.text(letters.charAt(int(map(b, 0, 255, 0, letters.length() - 1))), x * xStep, y * yStep);
    }
  }
  pg.endDraw();
  return pg.get();
}

public void selectSpriteSheet() {
  JFileChooser fc = new JFileChooser();
  fc.setCurrentDirectory(lastFolder != null ? lastFolder : new File(sketchPath("")));
  if (fc.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
    spriteSheet = loadImage(fc.getSelectedFile().getAbsolutePath());
    lastFolder = fc.getCurrentDirectory();
    regenerateFrames();
  }
}

void regenerateFrames() {
  if (spriteSheet == null) return;
  spriteWidth = spriteSheet.width / spriteCols;
  spriteHeight = spriteSheet.height / spriteRows;
  totalFrames = spriteCols * spriteRows;
  frames = new PImage[totalFrames];
  int index = 0;
  for (int y = 0; y < spriteRows; y++) {
    for (int x = 0; x < spriteCols; x++) {
      if (index >= totalFrames) break;
      PImage f = spriteSheet.get(x * spriteWidth, y * spriteHeight, spriteWidth, spriteHeight);
      f.resize(asciiCols, asciiRows);
      f.filter(GRAY);
      frames[index++] = f;
    }
  }
  currentFrame = 0;
}

void draw() {
  background(0);
  if (frames == null || frames.length == 0) {
    fill(255);
    text("Cargue un sprite sheet...", 150, height / 2);
    return;
  }
  PImage img = frames[currentFrame];
  float xStep = width / float(img.width);
  float yStep = height / float(img.height);
  img.loadPixels();
  textSize(charSize);
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int idx = y * img.width + x;
      if (idx >= img.pixels.length) continue;
      float b = brightness(img.pixels[idx]);
      b = (b - 128) * contrastAdjust + 128 + brightnessAdjust;
      b = constrain(b, 0, 255);
      if (threshold > 0) b = (b > threshold) ? 255 : 0;
      if (negativeMode) b = 255 - b;
      fill(asciiColor);
      text(letters.charAt(int(map(b, 0, 255, 0, letters.length() - 1))), x * xStep, y * yStep);
    }
  }
  if (frameCount % int(60.0 / frameSpeed) == 0) {
    currentFrame = (currentFrame + 1) % totalFrames;
  }
}

File selectFolder() {
  JFileChooser chooser = new JFileChooser();
  chooser.setCurrentDirectory(lastFolder != null ? lastFolder : new File(sketchPath("")));
  chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
  if (chooser.showSaveDialog(null) == JFileChooser.APPROVE_OPTION) {
    lastFolder = chooser.getSelectedFile();
    return chooser.getSelectedFile();
  }
  return null;
}
