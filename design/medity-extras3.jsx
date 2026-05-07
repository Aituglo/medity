function SecHead({ n, title }) {
  return (
    <div style={{ display:'flex', alignItems:'baseline', gap: 14 }}>
      <div style={{ fontFamily: 'ui-monospace, "SF Mono", monospace', fontSize: 11, color: M.ink3, letterSpacing: 2 }}>{n}</div>
      <div className="serif" style={{ fontSize: 26, fontWeight: 400, color: M.ink }}>{title}</div>
      <div style={{ flex: 1, height: 1, background: M.hairline }}/>
    </div>
  );
}

function Tile({ label, children }) {
  return (
    <div style={{ padding: 16, borderRadius: 18, border: `0.5px dashed ${M.hairline2}`, background:'rgba(255,255,255,0.3)' }}>
      <div style={{ fontSize: 10.5, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', marginBottom: 14 }}>{label}</div>
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// App icon
// ─────────────────────────────────────────────────────────────
function ScreenAppIcon() {
  return (
    <div style={{ width: 600, padding: 40, background: M.bg, borderRadius: 24, position:'relative', overflow:'hidden', boxShadow:'0 40px 80px rgba(15,27,45,0.18)' }}>
      <MBackdrop mood="dawn"/>
      <div style={{ position:'relative' }}>
        <SecHead n="04" title="App icon"/>
        <div style={{ marginTop: 24, display:'flex', alignItems:'center', gap: 36 }}>
          {/* Big icon — stacked stones */}
          <div style={{
            width: 220, height: 220, borderRadius: 50,
            background: 'radial-gradient(circle at 30% 25%, #F2F5FA 0%, #D7E1EF 35%, #B5C6DD 70%, #94AAC8 100%)',
            position:'relative', overflow:'hidden',
            boxShadow: '0 30px 60px rgba(74,111,165,0.30), inset 0 2px 0 rgba(255,255,255,0.7)',
            display:'flex', alignItems:'center', justifyContent:'center',
          }}>
            <div style={{ position:'absolute', inset: 24, borderRadius:'50%', background:'radial-gradient(circle, rgba(255,255,255,0.6), transparent 70%)' }}/>
            <div style={{ position:'relative', display:'flex', alignItems:'flex-end', justifyContent:'center' }}>
              <CairnMark size={130} ink={M.ink}/>
            </div>
          </div>

          {/* sizes */}
          <div style={{ display:'flex', flexDirection:'column', gap: 18 }}>
            {[120, 80, 56, 36].map(s => (
              <div key={s} style={{ display:'flex', alignItems:'center', gap: 16 }}>
                <div style={{
                  width: s, height: s, borderRadius: s * 0.225,
                  background: 'radial-gradient(circle at 30% 25%, #F2F5FA 0%, #D7E1EF 40%, #B5C6DD 75%, #94AAC8 100%)',
                  position:'relative', overflow:'hidden', boxShadow:'inset 0 1px 0 rgba(255,255,255,0.7), 0 4px 12px rgba(74,111,165,0.18)',
                  display:'flex', alignItems:'center', justifyContent:'center',
                }}>
                  <CairnMark size={s * 0.62} ink={M.ink}/>
                </div>
                <div style={{ fontSize: 11, color: M.ink3, fontFamily:'ui-monospace, "SF Mono", monospace' }}>{s}px</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ marginTop: 20, fontFamily: M.serif, fontStyle:'italic', fontSize: 15, color: M.ink2, maxWidth: 480 }}>
          A small cairn — three stacked stones — for balance, breath, and stillness. Soft blue gradient, no wordmark.
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  ScreenSettings, ScreenPaywall, ScreenWidgets, ScreenLiveActivity, ScreenStyleGuide, ScreenAppIcon,
  WidgetSmall, WidgetMedium, WidgetLarge, WidgetLockScreen, MiniRing, Tile, SecHead, SetRow, SetGroup, Annot,
});


// Medity — design canvas mounting all screens

const screens = [
  { id: 'onb1', label: '01 · Onboarding · Brand', w: 393, h: 852, c: <ScreenOnboarding1/> },
  { id: 'onb2', label: '02 · Onboarding · Features', w: 393, h: 852, c: <ScreenOnboarding2/> },
  { id: 'onb3', label: '03 · Onboarding · Permissions', w: 393, h: 852, c: <ScreenOnboarding3v2/> },
  { id: 'home', label: '04 · Home · Timer setup', w: 393, h: 852, c: <ScreenHome/>, annotations: [
    { x: 410, y: 320, w: 220, side:'right', label:'Drag the ring', sub:'4s breathing pulse on idle' },
    { x: -200, y: 540, w: 200, side:'left', label:'Preset chips', sub:'Horizontally scrollable' },
    { x: 410, y: 700, w: 220, side:'right', label:'Sound + Bells', sub:'Tap → modal sheet' },
  ]},
  { id: 'session', label: '05 · Session · In progress', w: 393, h: 852, c: <ScreenSession/>, annotations: [
    { x: 410, y: 100, w: 220, side:'right', label:'Tap to end', sub:'Low contrast on purpose' },
    { x: -240, y: 380, w: 230, side:'left', label:'Numbers crossfade', sub:'Never tick. mm:ss · tabular' },
    { x: 410, y: 380, w: 220, side:'right', label:'Soft mist drifts up', sub:'~22 particles, slow' },
    { x: -240, y: 760, w: 230, side:'left', label:'Pause only', sub:'No labels, no chrome' },
  ]},
  { id: 'complete', label: '06 · Session complete', w: 393, h: 852, c: <ScreenComplete/> },
  { id: 'sounds', label: '07 · Sound library', w: 393, h: 852, c: <ScreenSounds/>, annotations: [
    { x: 410, y: 200, w: 220, side:'right', label:'Sheet · glass', sub:'Drag-down to dismiss' },
    { x: -220, y: 400, w: 200, side:'left', label:'Long-press to set', sub:'Tap to preview' },
  ]},
  { id: 'bells', label: '08 · Bells picker', w: 393, h: 852, c: <ScreenBells/> },
  { id: 'stats', label: '09 · Stats · Practice', w: 393, h: 852, c: <ScreenStats/> },
  { id: 'achievements', label: '10 · Achievements', w: 393, h: 852, c: <ScreenAchievements/> },
  { id: 'settings', label: '11 · Settings', w: 393, h: 852, c: <ScreenSettings/> },
  { id: 'paywall', label: '12 · Medity Plus', w: 393, h: 852, c: <ScreenPaywall/> },
];

function App() {
  return (
    <DesignCanvas>
      <DCSection id="hero" title="Medity" subtitle="A meditation timer · iOS · light glass · serif numerals · light mode only">
        <DCArtboard id="brand" label="Brand & app icon" width={600} height={420}>
          <ScreenAppIcon/>
        </DCArtboard>
        <DCArtboard id="style" label="Style guide" width={920} height={1080}>
          <ScreenStyleGuide/>
        </DCArtboard>
      </DCSection>

      <DCSection id="onboarding" title="Onboarding" subtitle="Three slides — brand, features, permissions">
        {screens.slice(0,3).map(s => (
          <DCArtboard key={s.id} id={s.id} label={s.label} width={s.w} height={s.h}>
            {s.c}
          </DCArtboard>
        ))}
      </DCSection>

      <DCSection id="core" title="Core flow" subtitle="The home, the session, the close">
        {screens.slice(3,6).map(s => (
          <DCArtboard key={s.id} id={s.id} label={s.label} width={s.w + (s.annotations ? 460 : 0)} height={s.h}>
            <div style={{ position:'relative', width: s.w, height: s.h, marginLeft: s.annotations ? 230 : 0 }}>
              {s.c}
              {(s.annotations || []).map((a, i) => <MAnnotation key={i} {...a}/>)}
            </div>
          </DCArtboard>
        ))}
      </DCSection>

      <DCSection id="modals" title="Sound & bells" subtitle="Modal sheets on glass">
        {screens.slice(6,8).map(s => (
          <DCArtboard key={s.id} id={s.id} label={s.label} width={s.w + (s.annotations ? 460 : 0)} height={s.h}>
            <div style={{ position:'relative', width: s.w, height: s.h, marginLeft: s.annotations ? 230 : 0 }}>
              {s.c}
              {(s.annotations || []).map((a, i) => <MAnnotation key={i} {...a}/>)}
            </div>
          </DCArtboard>
        ))}
      </DCSection>

      <DCSection id="practice" title="Practice & progress" subtitle="Stats, markers, defaults — and the empty first day">
        <DCArtboard id="stats-empty" label="09a · Stats · First day (empty)" width={393} height={852}>
          <ScreenStatsEmpty/>
        </DCArtboard>
        {screens.slice(8,11).map(s => (
          <DCArtboard key={s.id} id={s.id} label={s.label} width={s.w} height={s.h}>
            {s.c}
          </DCArtboard>
        ))}
        <DCArtboard id="achievement-detail" label="10a · Achievement · Detail sheet" width={393} height={852}>
          <ScreenAchievementDetail/>
        </DCArtboard>
      </DCSection>

      <DCSection id="language" title="Sound & touch" subtitle="How Medity sounds in the ear and feels in the hand">
        <DCArtboard id="audio-haptic" label="Audio · Haptic language" width={920} height={920}>
          <ScreenAudioHaptic/>
        </DCArtboard>
      </DCSection>

      <DCSection id="commerce" title="Medity Plus" subtitle="One-time unlock">
        <DCArtboard id="paywall" label="12 · Paywall" width={393} height={852}>
          <ScreenPaywall/>
        </DCArtboard>
      </DCSection>

      <DCSection id="surfaces" title="System surfaces" subtitle="Widgets and live activity">
        <DCArtboard id="widgets" label="Home & lock-screen widgets" width={393} height={852}>
          <ScreenWidgets/>
        </DCArtboard>
        <DCArtboard id="liveactivity" label="Dynamic Island · live activity" width={393} height={852}>
          <ScreenLiveActivity/>
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
