// Screens 1-4: Onboarding x3, Home/Timer Setup

// ─────────────────────────────────────────────────────────────
// 01 — Onboarding · brand
// ─────────────────────────────────────────────────────────────
function ScreenOnboarding1() {
  return (
    <MPhone mood="dawn">
      <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
        <MAura size={420} style={{ top: '32%', left: '50%', transform:'translate(-50%,-50%)' }}/>
        {/* cairn mark — stacked stones */}
        <div style={{ marginBottom: 28, width: 96, height: 96, display:'flex', alignItems:'flex-end', justifyContent:'center' }}>
          <CairnMark size={80}/>
        </div>
        <div className="serif" style={{ fontSize: 64, color: M.ink, lineHeight: 1, letterSpacing: -0.5 }}>Medity</div>
        <div style={{ marginTop: 18, fontFamily: M.serif, fontSize: 19, color: M.ink2, fontStyle:'italic', fontWeight: 300 }}>A quieter mind, daily.</div>
      </div>
      {/* page dots */}
      <div style={{ position:'absolute', bottom: 130, left:0, right:0, display:'flex', gap: 6, justifyContent:'center' }}>
        <Dot active/><Dot/><Dot/>
      </div>
      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24 }}>
        <MPrimaryButton icon="arrow">Begin</MPrimaryButton>
      </div>
    </MPhone>
  );
}

function CairnMark({ size = 80, ink = M.ink }) {
  // Three stacked organic "stones" — bottom widest, top smallest
  return (
    <svg width={size} height={size * 1.05} viewBox="0 0 80 84" fill="none" style={{ display:'block' }}>
      {/* bottom stone */}
      <path d="M8 74 C 6 66, 14 58, 24 56 C 36 54, 52 56, 64 60 C 72 62, 76 70, 70 76 C 62 82, 46 82, 32 81 C 20 80, 10 80, 8 74 Z" fill={ink}/>
      {/* middle stone */}
      <path d="M18 50 C 16 42, 24 36, 34 35 C 46 34, 56 38, 60 44 C 64 50, 56 54, 44 54 C 32 54, 20 54, 18 50 Z" fill={ink}/>
      {/* top stone — smallest, slightly off-center */}
      <ellipse cx="42" cy="26" rx="12" ry="7.5" fill={ink}/>
    </svg>
  );
}

window.CairnMark = CairnMark;

function Dot({ active }) {
  return <div style={{ width: active ? 18 : 6, height: 6, borderRadius: 3, background: active ? M.ink : 'rgba(15,27,45,0.2)', transition:'all .3s' }} />;
}

// ─────────────────────────────────────────────────────────────
// 02 — Onboarding · features
// ─────────────────────────────────────────────────────────────
function ScreenOnboarding2() {
  const items = [
    { label: 'Timer', sub: 'Set any length. The ring is the dial.', icon: (
      <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
        <circle cx="16" cy="16" r="13" stroke={M.ink} strokeWidth="1" strokeDasharray="3 3"/>
        <circle cx="16" cy="16" r="13" stroke={M.accent} strokeWidth="1.4" strokeDasharray="20 60" strokeLinecap="round" transform="rotate(-90 16 16)"/>
        <circle cx="16" cy="3" r="2" fill={M.accent}/>
      </svg>
    )},
    { label: 'Sounds', sub: 'Rain, ocean, bowls, or silence.', icon: (
      <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
        <path d="M3 16c3-6 5-6 8 0s5 6 8 0 5-6 8 0" stroke={M.ink} strokeWidth="1.2" strokeLinecap="round"/>
        <path d="M3 22c3-3 5-3 8 0s5 3 8 0 5-3 8 0" stroke={M.ink2} strokeWidth="1" strokeLinecap="round" opacity="0.6"/>
      </svg>
    )},
    { label: 'Stats', sub: 'A small calendar of practice.', icon: (
      <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
        {[0,1,2,3].map(c => [0,1,2,3].map(r => (
          <rect key={c+'-'+r} x={3+c*7} y={3+r*7} width="5" height="5" rx="1" fill={M.accent} opacity={0.15 + ((c+r) % 4) * 0.18}/>
        )))}
      </svg>
    )},
  ];
  return (
    <MPhone mood="day">
      <div style={{ position:'absolute', inset:0, padding:'120px 36px 0', display:'flex', flexDirection:'column' }}>
        <div className="serif" style={{ fontSize: 38, color: M.ink, lineHeight: 1.05, letterSpacing: -0.5 }}>
          Three<br/>simple things.
        </div>
        <div style={{ marginTop: 56, display:'flex', flexDirection:'column', gap: 38 }}>
          {items.map(it => (
            <div key={it.label} style={{ display:'flex', gap: 22, alignItems:'flex-start' }}>
              <div style={{ width: 48, height: 48, flexShrink: 0, display:'flex', alignItems:'center', justifyContent:'center' }}>{it.icon}</div>
              <div>
                <div className="serif" style={{ fontSize: 24, color: M.ink, lineHeight: 1, fontWeight: 400 }}>{it.label}</div>
                <div style={{ marginTop: 6, fontSize: 15, color: M.ink2, lineHeight: 1.45 }}>{it.sub}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ position:'absolute', bottom: 130, left:0, right:0, display:'flex', gap: 6, justifyContent:'center' }}>
        <Dot/><Dot active/><Dot/>
      </div>
      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24 }}>
        <MPrimaryButton icon="arrow">Continue</MPrimaryButton>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// 03 — Onboarding · permissions
// ─────────────────────────────────────────────────────────────
function ScreenOnboarding3() {
  return (
    <MPhone mood="dusk">
      <div style={{ position:'absolute', inset:0, padding:'120px 28px 0' }}>
        <div className="serif" style={{ fontSize: 38, color: M.ink, lineHeight: 1.05, letterSpacing: -0.5, padding:'0 8px' }}>
          A few small<br/>permissions.
        </div>
        <div style={{ marginTop: 12, fontSize: 15, color: M.ink2, padding:'0 8px', lineHeight: 1.5 }}>
          Optional, and you can change either later in Settings.
        </div>

        <div style={{ marginTop: 40, display:'flex', flexDirection:'column', gap: 14 }}>
          <PermissionCard
            title="Mindful Minutes"
            sub="Save sessions to Apple Health so they count toward your day."
            icon={(
              <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
                <path d="M11 19s-7-4.4-7-10a4 4 0 017-2.6A4 4 0 0118 9c0 5.6-7 10-7 10z" stroke={M.accent} strokeWidth="1.4" strokeLinejoin="round"/>
              </svg>
            )}
            cta="Connect Health"
          />
          <PermissionCard
            title="Gentle reminders"
            sub="One quiet nudge a day, at the time you choose."
            icon={(
              <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
                <path d="M11 2v1.4M5.5 9C5.5 6 8 3.6 11 3.6S16.5 6 16.5 9v3.6L18.4 16H3.6l1.9-3.4V9z" stroke={M.accent} strokeWidth="1.4" strokeLinejoin="round" strokeLinecap="round"/>
                <path d="M9 18a2 2 0 004 0" stroke={M.accent} strokeWidth="1.4" strokeLinecap="round"/>
              </svg>
            )}
            cta="Allow notifications"
          />
        </div>
      </div>
      <div style={{ position:'absolute', bottom: 130, left:0, right:0, display:'flex', gap: 6, justifyContent:'center' }}>
        <Dot/><Dot/><Dot active/>
      </div>
      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24, display:'flex', flexDirection:'column', gap: 12, alignItems:'center' }}>
        <MPrimaryButton icon="arrow">Begin</MPrimaryButton>
        <div style={{ fontSize: 14, color: M.ink2 }}>Not now</div>
      </div>
    </MPhone>
  );
}

function PermissionCard({ title, sub, icon, cta }) {
  return (
    <MGlass radius={22} tint={0.55}>
      <div style={{ padding: 18 }}>
        <div style={{ display:'flex', gap: 14, alignItems:'flex-start' }}>
          <div style={{ width: 38, height: 38, borderRadius: 12, background:'rgba(74,111,165,0.10)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink: 0 }}>
            {icon}
          </div>
          <div style={{ flex: 1 }}>
            <div className="serif" style={{ fontSize: 20, color: M.ink, fontWeight: 400 }}>{title}</div>
            <div style={{ marginTop: 4, fontSize: 13.5, color: M.ink2, lineHeight: 1.45 }}>{sub}</div>
          </div>
        </div>
        <div style={{
          marginTop: 14, height: 1, background: M.hairline,
        }}/>
        <div style={{ marginTop: 14, fontSize: 15, color: M.accent, fontWeight: 500, textAlign:'center' }}>{cta}</div>
      </div>
    </MGlass>
  );
}

// ─────────────────────────────────────────────────────────────
// 04 — Home / Timer setup
// ─────────────────────────────────────────────────────────────
function TimerRing({ size = 270, value = 20, max = 60, showHandle = true }) {
  const r = size/2 - 18;
  const c = size/2;
  const angle = (value / max) * Math.PI * 2 - Math.PI/2;
  const hx = c + r * Math.cos(angle);
  const hy = c + r * Math.sin(angle);
  const circ = 2 * Math.PI * r;
  const dash = (value / max) * circ;
  const innerR = r - 22;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <defs>
        <radialGradient id="ringbg" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#fff" stopOpacity="0.85"/>
          <stop offset="60%" stopColor="#fff" stopOpacity="0.25"/>
          <stop offset="100%" stopColor="#fff" stopOpacity="0"/>
        </radialGradient>
        <linearGradient id="ringstroke" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#9DB7DB"/>
          <stop offset="50%" stopColor="#6B8DBF"/>
          <stop offset="100%" stopColor="#3D5F94"/>
        </linearGradient>
        <radialGradient id="handleglow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#fff"/>
          <stop offset="60%" stopColor="#fff" stopOpacity="0.4"/>
          <stop offset="100%" stopColor="#fff" stopOpacity="0"/>
        </radialGradient>
      </defs>

      {/* glass-filled center */}
      <circle cx={c} cy={c} r={innerR + 14} fill="url(#ringbg)"/>

      {/* outer subtle hairline */}
      <circle cx={c} cy={c} r={r + 10} stroke="rgba(15,27,45,0.05)" strokeWidth="0.5" fill="none"/>

      {/* track */}
      <circle cx={c} cy={c} r={r} stroke="rgba(15,27,45,0.06)" strokeWidth="2" fill="none"/>

      {/* tick marks — softer, fade with progress */}
      {Array.from({length: 60}).map((_, i) => {
        const a = (i/60) * Math.PI * 2 - Math.PI/2;
        const isMajor = i % 5 === 0;
        const passed = (i / 60) <= (value / max);
        const ir = isMajor ? r-8 : r-5;
        const or = isMajor ? r+4 : r+2;
        const x1 = c + ir * Math.cos(a), y1 = c + ir * Math.sin(a);
        const x2 = c + or * Math.cos(a), y2 = c + or * Math.sin(a);
        return <line key={i} x1={x1} y1={y1} x2={x2} y2={y2}
          stroke={passed ? M.accent : M.ink}
          strokeOpacity={passed ? (isMajor ? 0.55 : 0.30) : (isMajor ? 0.22 : 0.08)}
          strokeWidth={isMajor ? 1.2 : 0.6}
          strokeLinecap="round"/>;
      })}

      {/* progress arc — drawn over ticks */}
      <circle
        cx={c} cy={c} r={r}
        stroke="url(#ringstroke)" strokeWidth="2.5" fill="none"
        strokeDasharray={`${dash} ${circ}`}
        strokeLinecap="round"
        transform={`rotate(-90 ${c} ${c})`}
        opacity="0.85"
      />

      {/* major minute numerals */}
      {[0, 15, 30, 45].map(m => {
        const a = (m / 60) * Math.PI * 2 - Math.PI/2;
        const tr = r - 22;
        const tx = c + tr * Math.cos(a);
        const ty = c + tr * Math.sin(a);
        return <text key={m} x={tx} y={ty + 3} fontSize="9" fill={M.ink3} fontFamily={M.sans} textAnchor="middle" letterSpacing="1">{m === 0 ? '60' : m}</text>;
      })}

      {showHandle && (
        <g>
          {/* glow halo */}
          <circle cx={hx} cy={hy} r="20" fill="url(#handleglow)"/>
          {/* outer soft ring */}
          <circle cx={hx} cy={hy} r="13" fill="#fff" stroke="rgba(15,27,45,0.10)" strokeWidth="0.5"/>
          {/* inner accent dot */}
          <circle cx={hx} cy={hy} r="4.5" fill={M.accent}/>
          {/* center sheen */}
          <circle cx={hx - 1} cy={hy - 1.5} r="1.2" fill="#fff" opacity="0.6"/>
        </g>
      )}
    </svg>
  );
}

function ScreenHome() {
  const presets = [3, 5, 10, 15, 20, 30, 45, 60];
  return (
    <MPhone mood="dawn">
      {/* Top bar */}
      <div style={{ position:'absolute', top: 60, left: 0, right: 0, padding:'0 20px', display:'flex', justifyContent:'space-between', zIndex: 10 }}>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <div style={{ position:'relative', zIndex:1 }}>{Icons.settings()}</div>
        </MGlass>
        <div style={{ display:'flex', alignItems:'center', gap: 8 }}>
          <MGlass radius={9999} tint={0.55} style={{ padding:'8px 14px', display:'flex', alignItems:'center', gap: 8 }}>
            <span style={{ position:'relative', zIndex:1, fontFamily: M.sans, fontSize: 15, color: M.ink, fontWeight: 500 }}>12</span>
            <div style={{ position:'relative', zIndex:1 }}>{Icons.flame(M.warm)}</div>
          </MGlass>
          <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ position:'relative', zIndex:1 }}>{Icons.stats()}</div>
          </MGlass>
        </div>
      </div>

      {/* Center timer ring */}
      <div style={{ position:'absolute', inset: 0, top: 92, display:'flex', flexDirection:'column', alignItems:'center' }}>
        <div style={{ position:'relative', display:'flex', alignItems:'center', justifyContent:'center', width: 360, height: 360 }}>
          <MAura size={440} style={{ top:'50%', left:'50%', transform:'translate(-50%,-50%)' }}/>
          <TimerRing size={350} value={20}/>
          <div style={{ position:'absolute', display:'flex', flexDirection:'column', alignItems:'center' }}>
            <div style={{ display:'flex', alignItems:'baseline', gap: 8 }}>
              <div className="serif" style={{ fontSize: 132, color: M.ink, lineHeight: 0.9, fontWeight: 200, letterSpacing: -5 }}>20</div>
              <div style={{ fontSize: 19, color: M.ink2, fontWeight: 400, marginBottom: 20 }}>min</div>
            </div>
            <div style={{ marginTop: 4, fontSize: 10.5, color: M.ink3, letterSpacing: 3.5, textTransform:'uppercase', fontWeight: 500 }}>drag the dial</div>
          </div>
        </div>

        {/* presets */}
        <div style={{ marginTop: 20, width: '100%', overflow:'hidden' }}>
          <div style={{ display:'flex', gap: 8, padding:'0 24px', overflow:'visible' }}>
            {presets.map((p) => (
              <MGlass key={p} radius={9999} tint={p === 20 ? 0.92 : 0.5} blur={20} style={{
                padding:'10px 16px', flexShrink: 0,
                ...(p === 20 ? { boxShadow:'0 1px 1px rgba(15,27,45,0.04), 0 6px 20px rgba(74,111,165,0.18), inset 0 1px 0 rgba(255,255,255,0.9)' } : {}),
              }}>
                <span style={{ position:'relative', zIndex:1, fontFamily: M.sans, fontSize: 14, fontWeight: 500, color: p === 20 ? M.ink : M.ink2 }}>{p}</span>
              </MGlass>
            ))}
          </div>
        </div>

        {/* Sound + Bells pills */}
        <div style={{ marginTop: 18, padding:'0 24px', display:'flex', gap: 10, width:'100%', boxSizing:'border-box' }}>
          <MGlass radius={20} tint={0.55} style={{ flex: 1, padding:'14px 16px' }}>
            <div style={{ position:'relative', zIndex:1 }}>
              <div style={{ display:'flex', alignItems:'center', gap: 8, fontSize: 10.5, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', fontWeight: 500 }}>
                {Icons.wave(M.ink3)} Sound
              </div>
              <div style={{ marginTop: 6, fontSize: 15, color: M.ink, fontWeight: 500 }}>Rain · Light</div>
            </div>
          </MGlass>
          <MGlass radius={20} tint={0.55} style={{ flex: 1, padding:'14px 16px' }}>
            <div style={{ position:'relative', zIndex:1 }}>
              <div style={{ display:'flex', alignItems:'center', gap: 8, fontSize: 10.5, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', fontWeight: 500 }}>
                {Icons.bell(M.ink3)} Bells
              </div>
              <div style={{ marginTop: 6, fontSize: 15, color: M.ink, fontWeight: 500 }}>Start &amp; End</div>
            </div>
          </MGlass>
        </div>
      </div>

      {/* Begin */}
      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24 }}>
        <MPrimaryButton icon="play">20 min session</MPrimaryButton>
      </div>
    </MPhone>
  );
}

Object.assign(window, {
  ScreenOnboarding1, ScreenOnboarding2, ScreenOnboarding3, ScreenHome, TimerRing, PermissionCard, Dot,
});
