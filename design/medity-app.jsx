// Medity — design canvas mounting all screens

const screens = [
  { id: 'onb1', label: '01 · Onboarding · Brand', w: 393, h: 852, c: <ScreenOnboarding1/> },
  { id: 'onb2', label: '02 · Onboarding · Features', w: 393, h: 852, c: <ScreenOnboarding2/> },
  { id: 'onb3', label: '03 · Onboarding · Permissions', w: 393, h: 852, c: <ScreenOnboarding3/> },
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

      <DCSection id="practice" title="Practice & progress" subtitle="Stats, markers, defaults">
        {screens.slice(8,11).map(s => (
          <DCArtboard key={s.id} id={s.id} label={s.label} width={s.w} height={s.h}>
            {s.c}
          </DCArtboard>
        ))}
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
