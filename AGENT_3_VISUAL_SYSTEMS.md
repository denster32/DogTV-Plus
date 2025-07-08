# 🎨 AGENT 3: VISUAL SYSTEMS & UI
## Independent Work Stream - Minimal Dependencies

**Agent Focus:** Metal shaders, UI implementation, visual rendering, and user interface  
**Timeline:** 10 weeks  
**Dependencies:** Agent 1 (build system) - minimal coordination needed  
**Deliverables:** Working Metal shaders, complete UI, visual rendering system  

---

## 📋 **WEEK 1: METAL SHADER FOUNDATION**

### **TASK 1.1: METAL FRAMEWORK SETUP**
**Goal:** Set up Metal framework and basic rendering infrastructure
**Estimated Time:** 3 days
**Priority:** CRITICAL

#### **1.1.1: Metal Device Setup**
- [ ] **ACTION:** Create Metal device setup:
  ```swift
  class MetalRenderer {
      private let device: MTLDevice
      private let commandQueue: MTLCommandQueue
      private let library: MTLLibrary
      
      init() throws {
          guard let device = MTLCreateSystemDefaultDevice() else {
              throw MetalError.deviceNotSupported
          }
          self.device = device
          self.commandQueue = device.makeCommandQueue()!
          self.library = device.makeDefaultLibrary()!
      }
  }
  ```
- [ ] **ACTION:** Set up command queue
- [ ] **ACTION:** Create shader library
- [ ] **ACTION:** Set up render pipeline
- [ ] **GOAL:** Working Metal setup
- [ ] **DELIVERABLE:** MetalRenderer.swift

#### **1.1.2: Basic Shader Implementation**
- [ ] **ACTION:** Create basic vertex shader:
  ```metal
  #include <metal_stdlib>
  using namespace metal;
  
  struct VertexIn {
      float2 position [[attribute(0)]];
      float2 texCoord [[attribute(1)]];
  };
  
  struct VertexOut {
      float4 position [[position]];
      float2 texCoord;
  };
  
  vertex VertexOut vertex_shader(VertexIn in [[stage_in]]) {
      VertexOut out;
      out.position = float4(in.position, 0.0, 1.0);
      out.texCoord = in.texCoord;
      return out;
  }
  ```
- [ ] **ACTION:** Create basic fragment shader
- [ ] **ACTION:** Test basic rendering
- [ ] **ACTION:** Verify shader compilation
- [ ] **GOAL:** Basic Metal rendering
- [ ] **DELIVERABLE:** Basic shaders

### **TASK 1.2: RENDERING PIPELINE**
**Goal:** Set up complete rendering pipeline
**Estimated Time:** 2 days
**Priority:** CRITICAL

#### **1.2.1: Pipeline Setup**
- [ ] **ACTION:** Create render pipeline descriptor
- [ ] **ACTION:** Set up vertex descriptor
- [ ] **ACTION:** Configure blend states
- [ ] **ACTION:** Set up depth/stencil states
- [ ] **GOAL:** Working render pipeline
- [ ] **DELIVERABLE:** Render pipeline

#### **1.2.2: Buffer Management**
- [ ] **ACTION:** Create vertex buffer management
- [ ] **ACTION:** Set up uniform buffer management
- [ ] **ACTION:** Implement buffer pooling
- [ ] **ACTION:** Add buffer validation
- [ ] **GOAL:** Efficient buffer management
- [ ] **DELIVERABLE:** Buffer management system

---

## 📋 **WEEK 2: SCENE-SPECIFIC SHADERS**

### **TASK 2.1: OCEAN WAVES SHADER**
**Goal:** Implement ocean waves procedural shader
**Estimated Time:** 2 days
**Priority:** HIGH

#### **2.1.1: Ocean Shader Implementation**
- [ ] **ACTION:** Create ocean vertex shader:
  ```metal
  vertex VertexOut ocean_vertex_shader(VertexIn in [[stage_in]],
                                      constant float& time [[buffer(1)]]) {
      VertexOut out;
      out.position = float4(in.position, 0.0, 1.0);
      out.texCoord = in.texCoord;
      return out;
  }
  ```
- [ ] **ACTION:** Create ocean fragment shader:
  ```metal
  fragment float4 ocean_fragment_shader(VertexOut in [[stage_in]],
                                       constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create wave effect
      float wave1 = sin(uv.x * 10.0 + time) * 0.5 + 0.5;
      float wave2 = sin(uv.x * 20.0 + time * 2.0) * 0.3;
      float wave3 = sin(uv.y * 5.0 + time * 0.5) * 0.2;
      
      // Combine waves
      float wave = wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2;
      
      // Ocean colors
      float3 deepBlue = float3(0.0, 0.2, 0.6);
      float3 lightBlue = float3(0.0, 0.5, 1.0);
      float3 foam = float3(0.9, 0.95, 1.0);
      
      // Mix colors based on wave height
      float3 color = mix(deepBlue, lightBlue, wave);
      color = mix(color, foam, smoothstep(0.8, 1.0, wave));
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add wave animation
- [ ] **ACTION:** Implement color variations
- [ ] **ACTION:** Add foam effects
- [ ] **GOAL:** Realistic ocean waves
- [ ] **DELIVERABLE:** Ocean shader

### **TASK 2.2: FOREST CANOPY SHADER**
**Goal:** Implement forest canopy procedural shader
**Estimated Time:** 2 days
**Priority:** HIGH

#### **2.2.1: Forest Shader Implementation**
- [ ] **ACTION:** Create forest vertex shader
- [ ] **ACTION:** Create forest fragment shader:
  ```metal
  fragment float4 forest_fragment_shader(VertexOut in [[stage_in]],
                                        constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create tree canopy effect
      float noise = fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
      float trees = smoothstep(0.3, 0.7, noise);
      
      // Add wind movement
      float wind = sin(uv.x * 5.0 + time * 0.5) * 0.1;
      trees += wind * 0.1;
      
      // Forest colors
      float3 darkGreen = float3(0.1, 0.3, 0.1);
      float3 lightGreen = float3(0.2, 0.5, 0.2);
      float3 sunLight = float3(0.8, 0.7, 0.3);
      
      // Mix colors
      float3 color = mix(darkGreen, lightGreen, trees);
      color += sunLight * smoothstep(0.8, 1.0, uv.y) * 0.3;
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add wind animation
- [ ] **ACTION:** Implement sunlight effects
- [ ] **ACTION:** Add depth variation
- [ ] **GOAL:** Realistic forest canopy
- [ ] **DELIVERABLE:** Forest shader

### **TASK 2.3: FIREFLIES SHADER**
**Goal:** Implement fireflies procedural shader
**Estimated Time:** 1 day
**Priority:** MEDIUM

#### **2.3.1: Fireflies Shader Implementation**
- [ ] **ACTION:** Create fireflies vertex shader
- [ ] **ACTION:** Create fireflies fragment shader:
  ```metal
  fragment float4 fireflies_fragment_shader(VertexOut in [[stage_in]],
                                           constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create firefly positions
      float2 firefly1 = float2(0.3, 0.7);
      float2 firefly2 = float2(0.7, 0.3);
      float2 firefly3 = float2(0.5, 0.5);
      
      // Calculate distances
      float dist1 = distance(uv, firefly1);
      float dist2 = distance(uv, firefly2);
      float dist3 = distance(uv, firefly3);
      
      // Create pulsing effect
      float pulse1 = sin(time * 2.0) * 0.5 + 0.5;
      float pulse2 = sin(time * 1.5 + 1.0) * 0.5 + 0.5;
      float pulse3 = sin(time * 2.5 + 2.0) * 0.5 + 0.5;
      
      // Firefly glow
      float glow1 = smoothstep(0.1, 0.0, dist1) * pulse1;
      float glow2 = smoothstep(0.1, 0.0, dist2) * pulse2;
      float glow3 = smoothstep(0.1, 0.0, dist3) * pulse3;
      
      // Background
      float3 background = float3(0.0, 0.1, 0.2);
      float3 fireflyColor = float3(1.0, 1.0, 0.5);
      
      float3 color = background;
      color += fireflyColor * (glow1 + glow2 + glow3);
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add movement animation
- [ ] **ACTION:** Implement multiple fireflies
- [ ] **ACTION:** Add glow effects
- [ ] **GOAL:** Magical fireflies effect
- [ ] **DELIVERABLE:** Fireflies shader

---

## 📋 **WEEK 3: ADDITIONAL SCENE SHADERS**

### **TASK 3.1: GENTLE RAIN SHADER**
**Goal:** Implement gentle rain procedural shader
**Estimated Time:** 2 days
**Priority:** MEDIUM

#### **3.1.1: Rain Shader Implementation**
- [ ] **ACTION:** Create rain vertex shader
- [ ] **ACTION:** Create rain fragment shader:
  ```metal
  fragment float4 rain_fragment_shader(VertexOut in [[stage_in]],
                                      constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create raindrop effect
      float2 raindrop = float2(uv.x, fmod(uv.y + time * 0.5, 1.0));
      float drop = smoothstep(0.0, 0.02, raindrop.x) * 
                   smoothstep(0.02, 0.0, raindrop.x) *
                   smoothstep(0.0, 0.1, raindrop.y) *
                   smoothstep(0.1, 0.0, raindrop.y);
      
      // Multiple raindrops
      float2 raindrop2 = float2(fmod(uv.x + 0.3, 1.0), fmod(uv.y + time * 0.7, 1.0));
      float drop2 = smoothstep(0.0, 0.02, raindrop2.x) * 
                    smoothstep(0.02, 0.0, raindrop2.x) *
                    smoothstep(0.0, 0.1, raindrop2.y) *
                    smoothstep(0.1, 0.0, raindrop2.y);
      
      // Background
      float3 background = float3(0.2, 0.3, 0.4);
      float3 raindropColor = float3(0.7, 0.8, 1.0);
      
      float3 color = background;
      color += raindropColor * (drop + drop2);
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add rain intensity variation
- [ ] **ACTION:** Implement splash effects
- [ ] **ACTION:** Add fog effects
- [ ] **GOAL:** Realistic rain effect
- [ ] **DELIVERABLE:** Rain shader

### **TASK 3.2: SUNSET SHADER**
**Goal:** Implement sunset procedural shader
**Estimated Time:** 2 days
**Priority:** MEDIUM

#### **3.2.1: Sunset Shader Implementation**
- [ ] **ACTION:** Create sunset vertex shader
- [ ] **ACTION:** Create sunset fragment shader:
  ```metal
  fragment float4 sunset_fragment_shader(VertexOut in [[stage_in]],
                                        constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create gradient from bottom to top
      float gradient = uv.y;
      
      // Sunset colors
      float3 skyBlue = float3(0.5, 0.7, 1.0);
      float3 sunsetOrange = float3(1.0, 0.6, 0.3);
      float3 sunsetPink = float3(1.0, 0.4, 0.6);
      float3 nightBlue = float3(0.1, 0.1, 0.3);
      
      // Mix colors based on height
      float3 color;
      if (gradient < 0.3) {
          color = mix(sunsetOrange, sunsetPink, smoothstep(0.0, 0.3, gradient));
      } else if (gradient < 0.7) {
          color = mix(sunsetPink, skyBlue, smoothstep(0.3, 0.7, gradient));
      } else {
          color = mix(skyBlue, nightBlue, smoothstep(0.7, 1.0, gradient));
      }
      
      // Add sun
      float2 sunPos = float2(0.8, 0.2);
      float sunDist = distance(uv, sunPos);
      float sun = smoothstep(0.1, 0.05, sunDist);
      color += float3(1.0, 0.9, 0.5) * sun;
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add sun movement
- [ ] **ACTION:** Implement cloud effects
- [ ] **ACTION:** Add atmospheric scattering
- [ ] **GOAL:** Beautiful sunset effect
- [ ] **DELIVERABLE:** Sunset shader

### **TASK 3.3: STARRY NIGHT SHADER**
**Goal:** Implement starry night procedural shader
**Estimated Time:** 1 day
**Priority:** MEDIUM

#### **3.3.1: Stars Shader Implementation**
- [ ] **ACTION:** Create stars vertex shader
- [ ] **ACTION:** Create stars fragment shader:
  ```metal
  fragment float4 stars_fragment_shader(VertexOut in [[stage_in]],
                                       constant float& time [[buffer(1)]]) {
      float2 uv = in.texCoord;
      
      // Create star field
      float2 star1 = float2(0.2, 0.8);
      float2 star2 = float2(0.7, 0.9);
      float2 star3 = float2(0.5, 0.3);
      float2 star4 = float2(0.9, 0.1);
      float2 star5 = float2(0.1, 0.4);
      
      // Calculate star brightness
      float brightness1 = smoothstep(0.02, 0.0, distance(uv, star1));
      float brightness2 = smoothstep(0.02, 0.0, distance(uv, star2));
      float brightness3 = smoothstep(0.02, 0.0, distance(uv, star3));
      float brightness4 = smoothstep(0.02, 0.0, distance(uv, star4));
      float brightness5 = smoothstep(0.02, 0.0, distance(uv, star5));
      
      // Add twinkling effect
      float twinkle1 = sin(time * 3.0) * 0.5 + 0.5;
      float twinkle2 = sin(time * 2.5 + 1.0) * 0.5 + 0.5;
      float twinkle3 = sin(time * 4.0 + 2.0) * 0.5 + 0.5;
      float twinkle4 = sin(time * 1.5 + 3.0) * 0.5 + 0.5;
      float twinkle5 = sin(time * 3.5 + 4.0) * 0.5 + 0.5;
      
      // Background
      float3 background = float3(0.0, 0.0, 0.1);
      float3 starColor = float3(1.0, 1.0, 1.0);
      
      float3 color = background;
      color += starColor * (brightness1 * twinkle1 + 
                           brightness2 * twinkle2 + 
                           brightness3 * twinkle3 + 
                           brightness4 * twinkle4 + 
                           brightness5 * twinkle5);
      
      return float4(color, 1.0);
  }
  ```
- [ ] **ACTION:** Add star twinkling
- [ ] **ACTION:** Implement shooting stars
- [ ] **ACTION:** Add constellation effects
- [ ] **GOAL:** Magical starry night
- [ ] **DELIVERABLE:** Stars shader

---

## 📋 **WEEK 4: METAL VIEW INTEGRATION**

### **TASK 4.1: METAL VIEW WRAPPER**
**Goal:** Integrate Metal with SwiftUI
**Estimated Time:** 3 days
**Priority:** CRITICAL

#### **4.1.1: Metal View Implementation**
- [ ] **ACTION:** Create MetalView wrapper:
  ```swift
  import MetalKit
  import SwiftUI
  
  struct MetalView: UIViewRepresentable {
      let device: MTLDevice
      let commandQueue: MTLCommandQueue
      let sceneType: SceneType
      
      func makeUIView(context: Context) -> MTKView {
          let mtkView = MTKView()
          mtkView.device = device
          mtkView.delegate = context.coordinator
          mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
          mtkView.enableSetNeedsDisplay = true
          return mtkView
      }
      
      func updateUIView(_ uiView: MTKView, context: Context) {
          context.coordinator.sceneType = sceneType
      }
      
      func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }
      
      class Coordinator: NSObject, MTKViewDelegate {
          let parent: MetalView
          var sceneType: SceneType
          var renderer: MetalRenderer
          
          init(_ parent: MetalView) {
              self.parent = parent
              self.sceneType = parent.sceneType
              self.renderer = try! MetalRenderer()
          }
          
          func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
              renderer.resize(size: size)
          }
          
          func draw(in view: MTKView) {
              renderer.render(sceneType: sceneType, in: view)
          }
      }
  }
  ```
- [ ] **ACTION:** Set up render loop
- [ ] **ACTION:** Handle view lifecycle
- [ ] **ACTION:** Implement scene switching
- [ ] **GOAL:** Working Metal view
- [ ] **DELIVERABLE:** MetalView.swift

#### **4.1.2: Scene Rendering**
- [ ] **ACTION:** Implement scene switching logic
- [ ] **ACTION:** Add uniform buffer updates
- [ ] **ACTION:** Handle frame updates
- [ ] **ACTION:** Optimize rendering
- [ ] **GOAL:** Scene rendering working
- [ ] **DELIVERABLE:** Scene renderer

---

## 📋 **WEEK 5: MAIN UI IMPLEMENTATION**

### **TASK 5.1: MAIN APP STRUCTURE**
**Goal:** Implement main app structure
**Estimated Time:** 2 days
**Priority:** CRITICAL

#### **5.1.1: App Entry Point**
- [ ] **ACTION:** Create DogTVPlusApp.swift:
  ```swift
  @main
  struct DogTVPlusApp: App {
      @StateObject private var contentService = ContentService()
      @StateObject private var audioService = AudioService()
      @StateObject private var settingsService = SettingsService()
      
      var body: some Scene {
          WindowGroup {
              ContentView()
                  .environmentObject(contentService)
                  .environmentObject(audioService)
                  .environmentObject(settingsService)
          }
      }
  }
  ```
- [ ] **ACTION:** Configure environment objects
- [ ] **ACTION:** Set up app lifecycle
- [ ] **ACTION:** Configure app settings
- [ ] **GOAL:** Main app working
- [ ] **DELIVERABLE:** DogTVPlusApp.swift

#### **5.1.2: Content View**
- [ ] **ACTION:** Create ContentView.swift:
  ```swift
  struct ContentView: View {
      @EnvironmentObject var contentService: ContentService
      @EnvironmentObject var audioService: AudioService
      @State private var selectedTab = 0
      
      var body: some View {
          TabView(selection: $selectedTab) {
              SceneGridView()
                  .tabItem {
                      Image(systemName: "play.circle")
                      Text("Scenes")
                  }
                  .tag(0)
              
              SettingsView()
                  .tabItem {
                      Image(systemName: "gear")
                      Text("Settings")
                  }
                  .tag(1)
          }
          .accentColor(.blue)
      }
  }
  ```
- [ ] **ACTION:** Implement main view structure
- [ ] **ACTION:** Add navigation
- [ ] **ACTION:** Configure tab bar
- [ ] **GOAL:** Main content view
- [ ] **DELIVERABLE:** ContentView.swift

### **TASK 5.2: SCENE GRID VIEW**
**Goal:** Implement scene selection interface
**Estimated Time:** 3 days
**Priority:** HIGH

#### **5.2.1: Scene Grid Implementation**
- [ ] **ACTION:** Create SceneGridView.swift:
  ```swift
  struct SceneGridView: View {
      @EnvironmentObject var contentService: ContentService
      @State private var scenes: [Scene] = []
      
      private let columns = [
          GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
      ]
      
      var body: some View {
          NavigationView {
              ScrollView {
                  LazyVGrid(columns: columns, spacing: 20) {
                      ForEach(scenes) { scene in
                          SceneCard(scene: scene)
                              .onTapGesture {
                                  contentService.startScene(scene)
                              }
                      }
                  }
                  .padding()
              }
              .navigationTitle("DogTV+ Scenes")
              .onAppear {
                  loadScenes()
              }
          }
      }
      
      private func loadScenes() {
          scenes = [
              Scene(id: UUID(), name: "Ocean Waves", type: .ocean, description: "Gentle ocean waves", duration: 3600, isActive: false),
              Scene(id: UUID(), name: "Forest Canopy", type: .forest, description: "Peaceful forest", duration: 3600, isActive: false),
              Scene(id: UUID(), name: "Fireflies", type: .fireflies, description: "Magical fireflies", duration: 3600, isActive: false),
              Scene(id: UUID(), name: "Gentle Rain", type: .rain, description: "Soothing rain", duration: 3600, isActive: false),
              Scene(id: UUID(), name: "Sunset", type: .sunset, description: "Beautiful sunset", duration: 3600, isActive: false),
              Scene(id: UUID(), name: "Starry Night", type: .stars, description: "Magical stars", duration: 3600, isActive: false)
          ]
      }
  }
  ```
- [ ] **ACTION:** Implement grid layout
- [ ] **ACTION:** Add scene cards
- [ ] **ACTION:** Handle scene selection
- [ ] **GOAL:** Scene selection working
- [ ] **DELIVERABLE:** SceneGridView.swift

---

## 📋 **WEEK 6: SCENE CARDS & DETAILS**

### **TASK 6.1: SCENE CARD IMPLEMENTATION**
**Goal:** Implement scene card components
**Estimated Time:** 2 days
**Priority:** HIGH

#### **6.1.1: Scene Card Design**
- [ ] **ACTION:** Create SceneCard.swift:
  ```swift
  struct SceneCard: View {
      let scene: Scene
      
      var body: some View {
          VStack {
              MetalView(device: MTLCreateSystemDefaultDevice()!, 
                       commandQueue: MTLCreateSystemDefaultDevice()!.makeCommandQueue()!,
                       sceneType: scene.type)
                  .frame(height: 200)
                  .cornerRadius(12)
              
              VStack(alignment: .leading, spacing: 8) {
                  Text(scene.name)
                      .font(.title2)
                      .fontWeight(.semibold)
                  
                  Text(scene.description)
                      .font(.body)
                      .foregroundColor(.secondary)
                  
                  HStack {
                      Image(systemName: "clock")
                      Text("\(Int(scene.duration / 60)) min")
                          .font(.caption)
                  }
                  .foregroundColor(.secondary)
              }
              .padding()
          }
          .background(Color(.systemGray6))
          .cornerRadius(16)
          .shadow(radius: 4)
      }
  }
  ```
- [ ] **ACTION:** Add Metal view integration
- [ ] **ACTION:** Implement card styling
- [ ] **ACTION:** Add interaction feedback
- [ ] **GOAL:** Beautiful scene cards
- [ ] **DELIVERABLE:** SceneCard.swift

### **TASK 6.2: SCENE DETAIL VIEW**
**Goal:** Implement scene detail view
**Estimated Time:** 3 days
**Priority:** MEDIUM

#### **6.2.1: Scene Detail Implementation**
- [ ] **ACTION:** Create SceneDetailView.swift
- [ ] **ACTION:** Show scene information
- [ ] **ACTION:** Add play/stop controls
- [ ] **ACTION:** Add scene preview
- [ ] **GOAL:** Scene details working
- [ ] **DELIVERABLE:** SceneDetailView.swift

---

## 📋 **WEEK 7: SETTINGS UI**

### **TASK 7.1: SETTINGS VIEW IMPLEMENTATION**
**Goal:** Implement settings interface
**Estimated Time:** 3 days
**Priority:** MEDIUM

#### **7.1.1: Settings View**
- [ ] **ACTION:** Create SettingsView.swift:
  ```swift
  struct SettingsView: View {
      @EnvironmentObject var settingsService: SettingsService
      @EnvironmentObject var audioService: AudioService
      
      var body: some View {
          NavigationView {
              Form {
                  Section(header: Text("Audio Settings")) {
                      Toggle("Enable Audio", isOn: $settingsService.audioSettings.isEnabled)
                      
                      VStack(alignment: .leading) {
                          Text("Volume")
                          Slider(value: $settingsService.audioSettings.volume, in: 0...1)
                      }
                      
                      Picker("Frequency Range", selection: $settingsService.audioSettings.frequencyRange) {
                          ForEach(FrequencyRange.allCases, id: \.self) { range in
                              Text(range.description).tag(range)
                          }
                      }
                      
                      Toggle("Include Nature Sounds", isOn: $settingsService.audioSettings.includeNatureSounds)
                  }
                  
                  Section(header: Text("Preferences")) {
                      Toggle("Auto Play", isOn: $settingsService.userPreferences.autoPlay)
                      
                      VStack(alignment: .leading) {
                          Text("Session Duration")
                          Slider(value: $settingsService.userPreferences.sessionDuration, in: 900...7200)
                          Text("\(Int(settingsService.userPreferences.sessionDuration / 60)) minutes")
                              .font(.caption)
                              .foregroundColor(.secondary)
                      }
                      
                      Toggle("Notifications", isOn: $settingsService.userPreferences.notificationsEnabled)
                  }
                  
                  Section {
                      Button("Reset to Defaults") {
                          settingsService.resetToDefaults()
                      }
                      .foregroundColor(.red)
                  }
              }
              .navigationTitle("Settings")
          }
      }
  }
  ```
- [ ] **ACTION:** Add audio settings controls
- [ ] **ACTION:** Add user preferences
- [ ] **ACTION:** Add save/reset functionality
- [ ] **GOAL:** Settings working
- [ ] **DELIVERABLE:** SettingsView.swift

---

## 📋 **WEEK 8: PERFORMANCE OPTIMIZATION**

### **TASK 8.1: RENDERING OPTIMIZATION**
**Goal:** Optimize Metal rendering performance
**Estimated Time:** 3 days
**Priority:** MEDIUM

#### **8.1.1: Shader Optimization**
- [ ] **ACTION:** Optimize shader performance
- [ ] **ACTION:** Reduce GPU usage
- [ ] **ACTION:** Optimize frame rate
- [ ] **ACTION:** Test rendering performance
- [ ] **GOAL:** Smooth rendering
- [ ] **DELIVERABLE:** Optimized shaders

#### **8.1.2: Memory Optimization**
- [ ] **ACTION:** Optimize texture memory usage
- [ ] **ACTION:** Implement texture pooling
- [ ] **ACTION:** Reduce memory allocations
- [ ] **ACTION:** Profile memory usage
- [ ] **GOAL:** Low memory usage
- [ ] **DELIVERABLE:** Memory optimization

### **TASK 8.2: UI PERFORMANCE**
**Goal:** Optimize UI performance
**Estimated Time:** 2 days
**Priority:** MEDIUM

#### **8.2.1: UI Optimization**
- [ ] **ACTION:** Optimize SwiftUI performance
- [ ] **ACTION:** Reduce view updates
- [ ] **ACTION:** Optimize animations
- [ ] **ACTION:** Profile UI performance
- [ ] **GOAL:** Smooth UI
- [ ] **DELIVERABLE:** UI optimization

---

## 📋 **WEEK 9: ACCESSIBILITY & POLISH**

### **TASK 9.1: ACCESSIBILITY IMPLEMENTATION**
**Goal:** Implement comprehensive accessibility
**Estimated Time:** 2 days
**Priority:** MEDIUM

#### **9.1.1: Accessibility Features**
- [ ] **ACTION:** Add accessibility labels
- [ ] **ACTION:** Implement VoiceOver support
- [ ] **ACTION:** Add accessibility hints
- [ ] **ACTION:** Test accessibility
- [ ] **GOAL:** Accessible UI
- [ ] **DELIVERABLE:** Accessibility features

### **TASK 9.2: UI POLISH**
**Goal:** Final UI improvements
**Estimated Time:** 3 days
**Priority:** MEDIUM

#### **9.2.1: Visual Polish**
- [ ] **ACTION:** Improve visual design
- [ ] **ACTION:** Add animations
- [ ] **ACTION:** Improve accessibility
- [ ] **ACTION:** Test on different devices
- [ ] **GOAL:** Polished UI
- [ ] **DELIVERABLE:** UI polish

---

## 📋 **WEEK 10: TESTING & FINAL VERIFICATION**

### **TASK 10.1: UI TESTING**
**Goal:** Comprehensive UI testing
**Estimated Time:** 3 days
**Priority:** HIGH

#### **10.1.1: UI Test Implementation**
- [ ] **ACTION:** Create UI tests
- [ ] **ACTION:** Test navigation
- [ ] **ACTION:** Test interactions
- [ ] **ACTION:** Test accessibility
- [ ] **GOAL:** Working UI tests
- [ ] **DELIVERABLE:** UI test suite

### **TASK 10.2: FINAL VERIFICATION**
**Goal:** Final verification of visual systems
**Estimated Time:** 2 days
**Priority:** CRITICAL

#### **10.2.1: Final Testing**
- [ ] **ACTION:** Test all shaders
- [ ] **ACTION:** Test UI components
- [ ] **ACTION:** Test performance
- [ ] **ACTION:** Test accessibility
- [ ] **GOAL:** Production-ready visual systems
- [ ] **DELIVERABLE:** Verified visual systems

---

## 🎯 **AGENT 3 SUCCESS CRITERIA**

### **Quantitative Goals:**
- [ ] 60 FPS rendering consistently
- [ ] <100ms scene switching time
- [ ] <50MB GPU memory usage
- [ ] 100% shader compilation success
- [ ] All UI components working

### **Qualitative Goals:**
- [ ] Beautiful, realistic shaders
- [ ] Smooth, responsive UI
- [ ] Accessible design
- [ ] Professional visual quality
- [ ] Excellent user experience

---

## 📋 **AGENT 3 DELIVERABLES**

### **Required Files:**
1. `MetalRenderer.swift` - Metal rendering system
2. `OceanShader.metal` - Ocean waves shader
3. `ForestShader.metal` - Forest canopy shader
4. `FirefliesShader.metal` - Fireflies shader
5. `RainShader.metal` - Rain shader
6. `SunsetShader.metal` - Sunset shader
7. `StarsShader.metal` - Starry night shader
8. `MetalView.swift` - Metal view wrapper
9. `DogTVPlusApp.swift` - Main app
10. `ContentView.swift` - Main content view
11. `SceneGridView.swift` - Scene grid
12. `SceneCard.swift` - Scene cards
13. `SceneDetailView.swift` - Scene details
14. `SettingsView.swift` - Settings interface
15. UI test suite

### **Required Systems:**
1. Working Metal shaders
2. Complete UI implementation
3. Scene rendering system
4. Settings interface
5. Accessibility features
6. Performance optimization
7. UI test suite

---

## 🚨 **AGENT 3 RISKS & MITIGATION**

### **High Risk Items:**
1. **Shader Complexity:** Shaders may be too complex
2. **Performance Issues:** Rendering may be too slow
3. **UI Complexity:** UI may become too complex

### **Mitigation Strategies:**
1. **Keep Shaders Simple:** Focus on essential effects
2. **Performance Testing:** Test performance early
3. **Incremental Development:** Build UI step by step

---

**RESULT:** Beautiful, performant visual systems with excellent UI 