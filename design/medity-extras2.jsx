function ScreenWidgets() {
  return (
    <MPhone mood="dusk">
      {/* Faux home wallpaper darker */}
      <div style={{ position:'absolute', inset: 0,
        background:'linear-gradient(180deg,#5a6f8a,#324356 40%,#1f2a3a)',
      }}/>
      <div style={{ position:'absolute', inset: 0, padding:'74px 16px 80px', display:'flex', flexDirection:'column', gap: 14, alignItems:'center' }}>
        <div style={{ fontSize: 11, color:'rgba(255,255,255,0.6)', letterSpacing: 3, textTransform:'uppercase' }}>Home Screen widgets</div>

        <div style={{ display:'flex', gap: 14, marginTop: 4 }}>
          <WidgetSmall/>
          <div style={{ display:'flex', flexDirection:'column', justifyContent:'center', gap: 6, color:'#fff', alignItems:'flex-start' }}>
            <div className="serif" style={{ fontSize: 18, fontStyle:'italic', opacity: 0.9 }}>Small</div>
            <div style={{ fontSize: 11, opacity: 0.6 }}>Streak · flame</div>
          </div>
        </div>

        <div style={{ alignSelf:'flex-start' }}>
          <WidgetMedium/>
          <div className="serif" style={{ marginTop: 6, fontSize: 15, fontStyle:'italic', color:'rgba(255,255,255,0.9)' }}>Medium <span style={{ fontSize: 11, opacity: 0.5 }}>· streak + last + week</span></div>
        </div>

        <div style={{ alignSelf:'flex-start' }}>
          <WidgetLarge/>
          <div className="serif" style={{ marginTop: 6, fontSize: 15, fontStyle:'italic', color:'rgba(255,255,255,0.9)' }}>Large <span style={{ fontSize: 11, opacity: 0.5 }}>· heatmap + stats</span></div>
        </div>
      </div>

      {/* Lock-screen pill at top */}
      <div style={{ position:'absolute', top: 80, left: 0, right: 0, display:'flex', justifyContent:'center' }}>
        <WidgetLockScreen/>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// Live Activity / Dynamic Island states
// ─────────────────────────────────────────────────────────────
function MiniRing({ size = 28, p = 0.32, c = '#9CC2FF' }) {
  const r = size/2 - 2;
  const C = size/2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size}>
      <circle cx={C} cy={C} r={r} stroke="rgba(255,255,255,0.25)" strokeWidth="2" fill="none"/>
      <circle cx={C} cy={C} r={r} stroke={c} strokeWidth="2" fill="none"
        strokeDasharray={`${p * circ} ${circ}`} strokeLinecap="round"
        transform={`rotate(-90 ${C} ${C})`}/>
    </svg>
  );
}

function ScreenLiveActivity() {
  return (
    <MPhone mood="dusk" islandExpanded={true}
      islandContent={
        <div style={{ display:'flex', alignItems:'center', gap: 16, height:'100%' }}>
          <div style={{ width: 76, height: 76, borderRadius:'50%', display:'flex', alignItems:'center', justifyContent:'center', position:'relative' }}>
            <svg width="76" height="76">
              <circle cx="38" cy="38" r="32" stroke="rgba(255,255,255,0.18)" strokeWidth="3" fill="none"/>
              <circle cx="38" cy="38" r="32" stroke="#9CC2FF" strokeWidth="3" fill="none"
                strokeDasharray={`${0.32 * 2 * Math.PI * 32} ${2 * Math.PI * 32}`}
                strokeLinecap="round" transform="rotate(-90 38 38)"/>
            </svg>
            <div style={{ position:'absolute', fontSize: 9, color:'rgba(255,255,255,0.6)', letterSpacing: 2, textTransform:'uppercase', top: 30 }}>left</div>
            <div style={{ position:'absolute', fontFamily: M.serif, fontSize: 14, fontWeight: 400, top: 38 }}>13:42</div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, color:'rgba(255,255,255,0.6)', letterSpacing: 2, textTransform:'uppercase' }}>Medity</div>
            <div className="serif" style={{ fontSize: 24, fontWeight: 300, marginTop: 2 }}>20 min</div>
            <div style={{ fontSize: 12, color:'rgba(255,255,255,0.65)', marginTop: 2 }}>Rain · Light</div>
          </div>
          <div style={{ width: 44, height: 44, borderRadius:'50%', background:'rgba(255,255,255,0.12)', display:'flex', alignItems:'center', justifyContent:'center' }}>
            {Icons.pause('#fff')}
          </div>
        </div>
      }
    >
      {/* Dim home below */}
      <div style={{ position:'absolute', inset:0, background:'rgba(15,27,45,0.55)' }}/>

      {/* Compact + minimal previews */}
      <div style={{ position:'absolute', top: 200, left: 0, right: 0, display:'flex', flexDirection:'column', gap: 32, alignItems:'center' }}>
        <Annot label="Expanded" sub="Tap-and-hold from compact"/>
      </div>

      <div style={{ position:'absolute', bottom: 280, left: 0, right: 0, display:'flex', flexDirection:'column', gap: 22, alignItems:'center' }}>
        {/* Compact (live activity-style as second island) */}
        <div style={{ display:'flex', alignItems:'center', gap: 14 }}>
          <div style={{ minWidth: 126, height: 37, borderRadius: 24, background:'#0A0F18', display:'flex', alignItems:'center', justifyContent:'space-between', padding:'0 10px 0 14px', color:'#fff', gap: 30 }}>
            <div style={{ display:'flex', alignItems:'center', gap: 6 }}>
              <MiniRing/>
              <span style={{ fontFamily: M.serif, fontSize: 14 }}>13:42</span>
            </div>
          </div>
          <Annot label="Compact" sub="Default while playing"/>
        </div>

        <div style={{ display:'flex', alignItems:'center', gap: 14 }}>
          <div style={{ minWidth: 126, height: 37, borderRadius: 24, background:'#0A0F18', display:'flex', alignItems:'center', justifyContent:'space-between', padding:'0 14px', color:'#fff' }}>
            <MiniRing size={20} p={0.32}/>
            <div style={{ width: 60 }}/>
            <span style={{ fontFamily: M.serif, fontSize: 13 }}>13:42</span>
          </div>
          <Annot label="Minimal" sub="When sharing space with another activity"/>
        </div>
      </div>
    </MPhone>
  );
}

function Annot({ label, sub }) {
  return (
    <div style={{
      background: 'rgba(255,250,242,0.92)',
      border: '1px solid #d6c7b3',
      borderRadius: 4, padding: '6px 10px',
      fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace',
      fontSize: 10, color: '#5a4a2a', lineHeight: 1.35,
      whiteSpace:'nowrap',
    }}>
      <div style={{ fontWeight: 600 }}>{label}</div>
      {sub && <div style={{ color:'#8a7a52', fontSize: 9.5, marginTop: 2 }}>{sub}</div>}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Style guide
// ─────────────────────────────────────────────────────────────
function Swatch({ color, name, hex, dark }) {
  return (
    <div style={{ display:'flex', flexDirection:'column', gap: 6 }}>
      <div style={{ width: '100%', aspectRatio: '1.2 / 1', background: color, borderRadius: 14, border: '0.5px solid rgba(15,27,45,0.08)' }}/>
      <div style={{ fontSize: 12, color: M.ink, fontWeight: 500 }}>{name}</div>
      <div style={{ fontSize: 11, color: M.ink2, fontFamily:'ui-monospace, "SF Mono", monospace' }}>{hex}</div>
    </div>
  );
}

function ScreenStyleGuide() {
  return (
    <div style={{ width: 920, padding: 40, background: M.bg, borderRadius: 24, fontFamily: M.sans, color: M.ink, position:'relative', overflow:'hidden', boxShadow:'0 40px 80px rgba(15,27,45,0.18)' }}>
      <MBackdrop mood="dawn"/>
      <div style={{ position:'relative' }}>
        <div className="serif" style={{ fontSize: 44, fontWeight: 300, letterSpacing: -0.5 }}>Medity · style</div>
        <div style={{ marginTop: 6, fontFamily: M.serif, fontStyle:'italic', fontSize: 17, color: M.ink2 }}>A vocabulary for the quiet app.</div>

        {/* Color */}
        <div style={{ marginTop: 36 }}>
          <SecHead n="01" title="Color"/>
          <div style={{ display:'grid', gridTemplateColumns:'repeat(7,1fr)', gap: 14, marginTop: 16 }}>
            <Swatch color={M.bg} name="Background" hex="#F4F6F9"/>
            <Swatch color={M.glass} name="Glass surface" hex="rgba/55%"/>
            <Swatch color={M.ink} name="Ink" hex="#0F1B2D"/>
            <Swatch color={M.ink2} name="Ink secondary" hex="#6B7891"/>
            <Swatch color={M.ink3} name="Ink tertiary" hex="#A8B0BF"/>
            <Swatch color={M.accent} name="Accent" hex="#4A6FA5"/>
            <Swatch color={M.aura} name="Aura" hex="#C9D6E8"/>
          </div>
        </div>

        {/* Type */}
        <div style={{ marginTop: 40 }}>
          <SecHead n="02" title="Type"/>
          <div style={{ marginTop: 16, display:'grid', gridTemplateColumns:'1fr 1fr', gap: 24 }}>
            <div>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Numerals & display · Newsreader (≈ New York)</div>
              <div className="serif" style={{ fontSize: 96, fontWeight: 200, lineHeight: 0.9, marginTop: 6, letterSpacing: -2 }}>13:42</div>
              <div className="serif" style={{ fontSize: 36, fontWeight: 300, marginTop: 12, letterSpacing: -0.5 }}>A quieter mind.</div>
              <div className="serif" style={{ fontStyle:'italic', fontSize: 18, color: M.ink2, marginTop: 10 }}>Day twelve, streak unbroken.</div>
            </div>
            <div>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>UI & labels · SF Pro</div>
              <div style={{ fontSize: 28, fontWeight: 600, marginTop: 6 }}>Begin a session</div>
              <div style={{ fontSize: 17, marginTop: 8, color: M.ink }}>Body — sentence-cased, calm copy. Generous line height.</div>
              <div style={{ fontSize: 13, color: M.ink2, marginTop: 8, lineHeight: 1.6 }}>Secondary 13 · explanations, sub-labels.</div>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', marginTop: 8 }}>Caps · sections / labels</div>
            </div>
          </div>
        </div>

        {/* Components */}
        <div style={{ marginTop: 40 }}>
          <SecHead n="03" title="Components"/>
          <div style={{ marginTop: 16, display:'grid', gridTemplateColumns:'repeat(2, 1fr)', gap: 18 }}>
            <Tile label="Glass card">
              <MGlass radius={20} tint={0.55} style={{ padding: 18 }}>
                <div style={{ position:'relative', zIndex:1 }}>
                  <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Today</div>
                  <div className="serif" style={{ fontSize: 28, marginTop: 6, fontWeight: 300 }}>20 min · Rain</div>
                </div>
              </MGlass>
            </Tile>

            <Tile label="Glass primary button">
              <MPrimaryButton icon="play">Begin</MPrimaryButton>
            </Tile>

            <Tile label="List row">
              <MGlass radius={16} tint={0.55} style={{}}>
                <div style={{ position:'relative', zIndex:1, padding:'14px 16px', display:'flex', alignItems:'center' }}>
                  <div style={{ flex: 1, fontSize: 16 }}>Daily reminder</div>
                  <div style={{ width: 51, height: 31, borderRadius: 100, background: M.accent, position:'relative' }}>
                    <div style={{ position:'absolute', top: 2, right: 2, width: 27, height: 27, borderRadius:'50%', background:'#fff' }}/>
                  </div>
                </div>
              </MGlass>
            </Tile>

            <Tile label="Chip · selected / idle">
              <div style={{ display:'flex', gap: 8 }}>
                {[5,10,20,30,45].map(p => (
                  <MGlass key={p} radius={9999} tint={p === 20 ? 0.85 : 0.5} blur={20} style={{ padding:'10px 16px' }}>
                    <span style={{ position:'relative', zIndex:1, fontFamily: M.serif, fontSize: 16, color: p === 20 ? M.ink : M.ink2 }}>{p}</span>
                  </MGlass>
                ))}
              </div>
            </Tile>

            <Tile label="Segmented control">
              <Segmented options={['Off','5 min','10 min','15 min']} active="10 min"/>
            </Tile>

            <Tile label="Toggle">
              <div style={{ display:'flex', gap: 14 }}>
                <div style={{ width: 51, height: 31, borderRadius: 100, background: M.accent, position:'relative' }}>
                  <div style={{ position:'absolute', top: 2, right: 2, width: 27, height: 27, borderRadius:'50%', background:'#fff', boxShadow:'0 2px 4px rgba(0,0,0,0.15)' }}/>
                </div>
                <div style={{ width: 51, height: 31, borderRadius: 100, background:'rgba(15,27,45,0.12)', position:'relative' }}>
                  <div style={{ position:'absolute', top: 2, left: 2, width: 27, height: 27, borderRadius:'50%', background:'#fff', boxShadow:'0 2px 4px rgba(0,0,0,0.15)' }}/>
                </div>
              </div>
            </Tile>
          </div>
        </div>
      </div>
    </div>
  );
}
