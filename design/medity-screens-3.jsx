// Screens 9-12: Stats, Achievements, Settings, Paywall

// ─────────────────────────────────────────────────────────────
// 09 — Stats
// ─────────────────────────────────────────────────────────────
function Heatmap() {
  // 26 weeks (~6 months) × 7 days
  const weeks = 26;
  const cell = 11.6;
  const gap = 3;
  const W = weeks * (cell + gap) - gap;
  const H = 7 * (cell + gap) - gap;

  // deterministic pseudo-random fill levels 0-4
  const data = [];
  for (let w = 0; w < weeks; w++) {
    for (let d = 0; d < 7; d++) {
      const x = (Math.sin((w*7+d)*1.7) + 1) / 2;
      const y = (Math.cos((w+d)*0.9) + 1) / 2;
      let lvl = Math.floor((x * 0.7 + y * 0.3) * 5);
      // weight recent weeks higher
      if (w > 18) lvl = Math.min(4, lvl + 1);
      if (w === weeks - 1 && d > 4) lvl = 0; // future days
      data.push(lvl);
    }
  }

  const colors = [
    'rgba(15,27,45,0.05)',
    'rgba(74,111,165,0.18)',
    'rgba(74,111,165,0.36)',
    'rgba(74,111,165,0.58)',
    'rgba(74,111,165,0.85)',
  ];
  return (
    <svg width={W} height={H + 16} viewBox={`0 0 ${W} ${H + 16}`}>
      {data.map((lvl, i) => {
        const w = Math.floor(i / 7), d = i % 7;
        return <rect key={i} x={w*(cell+gap)} y={d*(cell+gap)} width={cell} height={cell} rx="2.5" fill={colors[lvl]}/>
      })}
      {['Mar','Apr','May','Jun','Jul','Aug'].map((m, i) => (
        <text key={m} x={i * ((W - 16) / 6) + 4} y={H + 12} fontSize="9" fill={M.ink3} fontFamily={M.sans} letterSpacing="1">{m}</text>
      ))}
    </svg>
  );
}

function MetricTile({ label, value, unit, sub }) {
  return (
    <MGlass radius={20} tint={0.55} style={{ padding: 18 }}>
      <div style={{ position:'relative', zIndex:1 }}>
        <div style={{ fontSize: 10.5, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>{label}</div>
        <div style={{ marginTop: 10, display:'flex', alignItems:'baseline', gap: 4 }}>
          <div className="serif" style={{ fontSize: 36, color: M.ink, fontWeight: 300, lineHeight: 1, letterSpacing: -1 }}>{value}</div>
          <div style={{ fontSize: 13, color: M.ink2 }}>{unit}</div>
        </div>
        {sub && <div style={{ marginTop: 6, fontSize: 12, color: M.ink3 }}>{sub}</div>}
      </div>
    </MGlass>
  );
}

function LineGraph() {
  // 30 days
  const points = Array.from({length: 30}).map((_, i) => {
    const v = 10 + Math.sin(i * 0.6) * 6 + (i % 7 === 0 ? -8 : 0) + (i / 4);
    return Math.max(0, v);
  });
  const W = 320, H = 70;
  const max = Math.max(...points) * 1.1;
  const xs = (i) => (i / (points.length - 1)) * W;
  const ys = (v) => H - (v / max) * H;
  const path = points.map((v, i) => `${i === 0 ? 'M' : 'L'} ${xs(i)} ${ys(v)}`).join(' ');
  const fill = `${path} L ${W} ${H} L 0 ${H} Z`;
  return (
    <svg width="100%" height={H + 16} viewBox={`0 0 ${W} ${H + 16}`}>
      <defs>
        <linearGradient id="lgrad" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={M.accent} stopOpacity="0.25"/>
          <stop offset="100%" stopColor={M.accent} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={fill} fill="url(#lgrad)"/>
      <path d={path} stroke={M.accent} strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
      {points.map((v, i) => i % 4 === 0 && <circle key={i} cx={xs(i)} cy={ys(v)} r="2" fill={M.accent}/>)}
    </svg>
  );
}

function ScreenStats() {
  return (
    <MPhone mood="day">
      {/* nav */}
      <div style={{ position:'absolute', top: 60, left: 0, right: 0, padding:'0 20px', display:'flex', justifyContent:'space-between', zIndex: 10 }}>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="14" height="14" viewBox="0 0 14 14" style={{ position:'relative', zIndex:1 }}><path d="M9 1L3 7l6 6" stroke={M.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" fill="none"/></svg>
        </MGlass>
        <div className="serif" style={{ fontSize: 18, color: M.ink, alignSelf:'center' }}>Practice</div>
        <div style={{ width: 44 }}/>
      </div>

      <div style={{ position:'absolute', top: 110, left: 0, right: 0, bottom: 50, overflowY:'auto', padding:'10px 14px 30px' }}>
        {/* streak hero */}
        <MGlass radius={28} tint={0.6} style={{ padding: 24 }}>
          <div style={{ position:'relative', zIndex:1, display:'flex', alignItems:'center', justifyContent:'space-between' }}>
            <div>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 3, textTransform:'uppercase' }}>Current</div>
              <div style={{ marginTop: 6, display:'flex', alignItems:'baseline', gap: 10 }}>
                <div className="serif" style={{ fontSize: 88, color: M.ink, fontWeight: 200, lineHeight: 0.9, letterSpacing: -3 }}>12</div>
                <div className="serif" style={{ fontSize: 19, color: M.ink2, fontStyle:'italic' }}>day streak</div>
              </div>
              <div style={{ marginTop: 10, fontSize: 12.5, color: M.ink3 }}>Freezes remaining · 1 of 2</div>
            </div>
            <div style={{ width: 64, height: 64, borderRadius:'50%', background:'rgba(74,111,165,0.10)', display:'flex', alignItems:'center', justifyContent:'center' }}>
              <svg width="28" height="34" viewBox="0 0 16 20" fill="none">
                <path d="M8 1c0 4-5 5-5 11a5 5 0 0010 0c0-3-2-4-2-7 0 0-3 1-3 4 0-3 0-5 0-8z" stroke={M.accent} strokeWidth="1.2" strokeLinejoin="round"/>
              </svg>
            </div>
          </div>
        </MGlass>

        {/* heatmap */}
        <MGlass radius={24} tint={0.55} style={{ marginTop: 14, padding: 18 }}>
          <div style={{ position:'relative', zIndex:1 }}>
            <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Six months</div>
              <div style={{ fontSize: 11, color: M.ink3 }}>132 sessions</div>
            </div>
            <div style={{ marginTop: 10, overflowX:'auto' }}>
              <Heatmap/>
            </div>
            <div style={{ marginTop: 6, display:'flex', alignItems:'center', gap: 6, fontSize: 10, color: M.ink3 }}>
              <span>Less</span>
              {[0,1,2,3,4].map(i => (
                <div key={i} style={{ width: 9, height: 9, borderRadius: 2, background: ['rgba(15,27,45,0.05)','rgba(74,111,165,0.18)','rgba(74,111,165,0.36)','rgba(74,111,165,0.58)','rgba(74,111,165,0.85)'][i] }}/>
              ))}
              <span>More</span>
            </div>
          </div>
        </MGlass>

        {/* metrics 2x2 */}
        <div style={{ marginTop: 14, display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
          <MetricTile label="Total time" value="42" unit="hrs" sub="Since March"/>
          <MetricTile label="This week" value="2.4" unit="hrs" sub="+18 min vs last"/>
          <MetricTile label="Avg session" value="19" unit="min" sub="Median 20"/>
          <MetricTile label="Sessions" value="132" sub="6 this week"/>
        </div>

        {/* line graph */}
        <MGlass radius={24} tint={0.55} style={{ marginTop: 14, padding: 18 }}>
          <div style={{ position:'relative', zIndex:1 }}>
            <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
              <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Minutes per day</div>
              <div style={{ fontSize: 11, color: M.ink3 }}>Last 30</div>
            </div>
            <div style={{ marginTop: 14 }}>
              <LineGraph/>
            </div>
          </div>
        </MGlass>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// 10 — Achievements
// ─────────────────────────────────────────────────────────────
const badges = [
  { id: 1, name: 'First session', date: 'Mar 4', unlocked: true, icon: 'spark' },
  { id: 2, name: '7 day streak', date: 'Mar 12', unlocked: true, icon: 'streak' },
  { id: 3, name: '10 hours', date: 'Apr 27', unlocked: true, icon: 'hours' },
  { id: 4, name: '30 day streak', locked: 'In 18 days', unlocked: false, icon: 'streak30' },
  { id: 5, name: 'Early bird', date: 'before 7am', unlocked: true, icon: 'sun' },
  { id: 6, name: 'Night owl', locked: '0 / 5', unlocked: false, icon: 'moon' },
  { id: 7, name: '100 sessions', date: 'Jul 18', unlocked: true, icon: 'cent' },
  { id: 8, name: 'Marathon', locked: '60-min session', unlocked: false, icon: 'mara' },
  { id: 9, name: '50 hours', locked: '7h 50m left', unlocked: false, icon: 'h50' },
];

function BadgeIcon({ kind, c }) {
  const stroke = { stroke: c, strokeWidth: 1.3, fill: 'none', strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (kind) {
    case 'spark': return <svg width="36" height="36" viewBox="0 0 36 36"><path d="M18 7v22M7 18h22M11 11l14 14M25 11L11 25" {...stroke}/></svg>;
    case 'streak': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="11" {...stroke}/><text x="18" y="22" fontSize="11" fill={c} textAnchor="middle" fontFamily={M.serif}>7</text></svg>;
    case 'streak30': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="11" {...stroke}/><text x="18" y="22" fontSize="10" fill={c} textAnchor="middle" fontFamily={M.serif}>30</text></svg>;
    case 'hours': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="12" {...stroke}/><path d="M18 11v7l5 3" {...stroke}/></svg>;
    case 'sun': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="6" {...stroke}/><path d="M18 5v3M18 28v3M5 18h3M28 18h3M9 9l2 2M25 25l2 2M9 27l2-2M25 11l2-2" {...stroke}/></svg>;
    case 'moon': return <svg width="36" height="36" viewBox="0 0 36 36"><path d="M25 22A10 10 0 0114 11a8 8 0 1011 11z" {...stroke}/></svg>;
    case 'cent': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="12" {...stroke}/><text x="18" y="22" fontSize="10" fill={c} textAnchor="middle" fontFamily={M.serif}>100</text></svg>;
    case 'mara': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="12" {...stroke}/><circle cx="18" cy="18" r="3" fill={c}/><path d="M18 6v3M18 27v3M6 18h3M27 18h3" {...stroke}/></svg>;
    case 'h50': return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="12" {...stroke}/><text x="18" y="22" fontSize="11" fill={c} textAnchor="middle" fontFamily={M.serif}>50</text></svg>;
    default: return <svg width="36" height="36" viewBox="0 0 36 36"><circle cx="18" cy="18" r="11" {...stroke}/></svg>;
  }
}

function Badge({ b }) {
  const c = b.unlocked ? M.accent : M.ink3;
  return (
    <MGlass radius={18} tint={b.unlocked ? 0.6 : 0.4} style={{ padding: '18px 8px', textAlign:'center' }}>
      <div style={{ position:'relative', zIndex:1, display:'flex', flexDirection:'column', alignItems:'center', gap: 8, opacity: b.unlocked ? 1 : 0.55 }}>
        <div style={{ width: 56, height: 56, borderRadius:'50%', background: b.unlocked ? 'rgba(74,111,165,0.10)' : 'rgba(15,27,45,0.04)', display:'flex', alignItems:'center', justifyContent:'center', position:'relative' }}>
          <BadgeIcon kind={b.icon} c={c}/>
          {!b.unlocked && (
            <div style={{ position:'absolute', bottom: -2, right: -2, background: M.bg, width: 18, height: 18, borderRadius:'50%', display:'flex', alignItems:'center', justifyContent:'center' }}>
              {Icons.lock(M.ink3)}
            </div>
          )}
        </div>
        <div className="serif" style={{ fontSize: 13.5, color: M.ink, lineHeight: 1.15 }}>{b.name}</div>
        <div style={{ fontSize: 10.5, color: M.ink3 }}>{b.unlocked ? b.date : b.locked}</div>
      </div>
    </MGlass>
  );
}

function ScreenAchievements() {
  return (
    <MPhone mood="day">
      <div style={{ position:'absolute', top: 60, left: 0, right: 0, padding:'0 20px', display:'flex', justifyContent:'space-between', zIndex: 10 }}>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="14" height="14" viewBox="0 0 14 14" style={{ position:'relative', zIndex:1 }}><path d="M9 1L3 7l6 6" stroke={M.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" fill="none"/></svg>
        </MGlass>
        <div className="serif" style={{ fontSize: 18, color: M.ink, alignSelf:'center' }}>Markers</div>
        <div style={{ width: 44 }}/>
      </div>

      <div style={{ position:'absolute', top: 116, left: 0, right: 0, bottom: 36, overflowY:'auto', padding:'12px 16px 24px' }}>
        <div className="serif" style={{ fontSize: 30, color: M.ink, padding:'8px 4px 4px', fontWeight: 400, letterSpacing: -0.3 }}>4 of 9</div>
        <div style={{ fontSize: 13.5, color: M.ink2, padding:'0 4px 18px' }}>Quiet acknowledgements of practice.</div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap: 10 }}>
          {badges.map(b => <Badge key={b.id} b={b}/>)}
        </div>
      </div>
    </MPhone>
  );
}

Object.assign(window, { ScreenStats, ScreenAchievements, Heatmap, MetricTile, LineGraph, BadgeIcon, Badge });
