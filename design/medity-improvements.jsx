// Improvements: empty stats, achievement detail, redesigned onboarding 3, audio/haptic style page

// ─────────────────────────────────────────────────────────────
// Empty stats — first-time / day 1
// ─────────────────────────────────────────────────────────────
function ScreenStatsEmpty() {
  return (
    <MPhone mood="dawn">
      <div style={{ position:'absolute', top: 60, left: 0, right: 0, padding:'0 20px', display:'flex', justifyContent:'space-between', zIndex: 10 }}>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <svg width="14" height="14" viewBox="0 0 14 14" style={{ position:'relative', zIndex:1 }}>
            <path d="M9 1L3 7l6 6" stroke={M.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
          </svg>
        </MGlass>
        <div style={{ fontFamily: M.sans, fontSize: 16, color: M.ink, alignSelf:'center', fontWeight: 500 }}>Practice</div>
        <div style={{ width: 44 }}/>
      </div>

      <div style={{ position:'absolute', inset:0, top: 120, display:'flex', flexDirection:'column', alignItems:'center', padding:'0 36px', textAlign:'center' }}>
        <MAura size={300} style={{ top: 80, left:'50%', transform:'translateX(-50%)' }}/>

        {/* a small empty cairn — only one stone */}
        <div style={{ marginTop: 60, opacity: 0.7 }}>
          <svg width="84" height="84" viewBox="0 0 80 84" fill="none">
            <ellipse cx="40" cy="58" rx="28" ry="9" fill="rgba(15,27,45,0.10)"/>
            <ellipse cx="40" cy="50" rx="20" ry="6.5" fill="rgba(15,27,45,0.18)"/>
          </svg>
        </div>

        <div className="serif" style={{ marginTop: 36, fontSize: 36, color: M.ink, fontWeight: 200, letterSpacing: -1, lineHeight: 1.1 }}>
          The first stone.
        </div>
        <div style={{ marginTop: 14, fontSize: 14.5, color: M.ink2, lineHeight: 1.55, maxWidth: 260 }}>
          A single session begins your practice. The cairn grows from here — one stone, one quiet day at a time.
        </div>

        <div style={{ marginTop: 40, display:'flex', flexDirection:'column', gap: 8, alignItems:'center', fontSize: 12.5, color: M.ink3 }}>
          <div style={{ display:'flex', alignItems:'center', gap: 8 }}>
            <div style={{ width: 6, height: 6, borderRadius:'50%', background: M.ink3 }}/>
            <span>Sessions appear as squares on a calendar</span>
          </div>
          <div style={{ display:'flex', alignItems:'center', gap: 8 }}>
            <div style={{ width: 6, height: 6, borderRadius:'50%', background: M.ink3 }}/>
            <span>Streak begins on day two</span>
          </div>
        </div>
      </div>

      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24 }}>
        <MPrimaryButton icon="play">First session</MPrimaryButton>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// Achievement detail sheet
// ─────────────────────────────────────────────────────────────
function ScreenAchievementDetail() {
  return (
    <MPhone mood="day">
      {/* Backdrop grid (suggesting other achievements) */}
      <div style={{ position:'absolute', inset:0, opacity: 0.35, padding:'120px 16px', display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap: 10 }}>
        {Array.from({length: 9}).map((_, i) => (
          <div key={i} style={{ height: 110, borderRadius: 18, background: 'rgba(255,255,255,0.55)' }}/>
        ))}
      </div>
      <div style={{ position:'absolute', inset:0, background:'rgba(244,246,249,0.55)', backdropFilter:'blur(8px)' }}/>

      {/* Sheet */}
      <div style={{ position:'absolute', left: 16, right: 16, top: 130, bottom: 110,
        background:'rgba(255,255,255,0.78)',
        backdropFilter:'blur(40px)', WebkitBackdropFilter:'blur(40px)',
        borderRadius: 32,
        boxShadow:'0 24px 60px rgba(15,27,45,0.16), inset 0 1px 0 rgba(255,255,255,0.8)',
        border:`0.5px solid ${M.hairline}`,
        padding: '28px 24px',
        display:'flex', flexDirection:'column', alignItems:'center', textAlign:'center',
      }}>
        {/* close */}
        <div style={{ position:'absolute', top: 18, right: 18 }}>
          <MGlass radius={20} tint={0.4} style={{ width: 32, height: 32, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ position:'relative', zIndex:1 }}>{Icons.close()}</div>
          </MGlass>
        </div>

        <MAura size={220} hue={M.warmSoft} style={{ top: 60, left: '50%', transform:'translateX(-50%)' }}/>

        <div style={{ marginTop: 16, width: 96, height: 96, borderRadius:'50%', background:'rgba(198,139,92,0.12)', display:'flex', alignItems:'center', justifyContent:'center', position:'relative' }}>
          <svg width="48" height="48" viewBox="0 0 36 36" fill="none">
            <circle cx="18" cy="18" r="13" stroke={M.warm} strokeWidth="1.2"/>
            <text x="18" y="23" fontSize="13" fill={M.warm} textAnchor="middle" fontFamily={M.sans} fontWeight="500">7</text>
          </svg>
        </div>

        <div className="serif" style={{ marginTop: 22, fontSize: 32, color: M.ink, fontWeight: 200, letterSpacing: -0.7 }}>Seven days.</div>
        <div style={{ marginTop: 8, fontSize: 14, color: M.ink2, lineHeight: 1.55, maxWidth: 280 }}>
          A full week of practice. The first marker — small, but the rhythm is real.
        </div>

        <div style={{ marginTop: 28, padding:'14px 0', display:'flex', justifyContent:'space-around', alignSelf:'stretch', borderTop:`0.5px solid ${M.hairline}`, borderBottom:`0.5px solid ${M.hairline}` }}>
          <DetailStat label="Earned" value="Mar 12"/>
          <DetailStat label="Total minutes" value="142"/>
          <DetailStat label="Avg session" value="20"/>
        </div>

        <div style={{ marginTop: 18, fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', fontWeight: 500 }}>Up next</div>
        <div style={{ marginTop: 10, padding:'12px 18px', borderRadius: 14, background:'rgba(74,111,165,0.08)', display:'flex', alignItems:'center', gap: 12 }}>
          <svg width="22" height="22" viewBox="0 0 36 36" fill="none">
            <circle cx="18" cy="18" r="11" stroke={M.accent} strokeWidth="1.2"/>
            <text x="18" y="22" fontSize="10" fill={M.accent} textAnchor="middle" fontFamily={M.sans} fontWeight="500">30</text>
          </svg>
          <div style={{ textAlign:'left' }}>
            <div style={{ fontSize: 13, color: M.ink, fontWeight: 500 }}>Thirty days</div>
            <div style={{ fontSize: 11.5, color: M.ink2, marginTop: 1 }}>23 days to go · 77% there</div>
          </div>
        </div>
      </div>
    </MPhone>
  );
}

function DetailStat({ label, value }) {
  return (
    <div>
      <div style={{ fontSize: 10, color: M.ink3, letterSpacing: 2, textTransform:'uppercase', fontWeight: 500 }}>{label}</div>
      <div className="serif" style={{ marginTop: 4, fontSize: 18, color: M.ink, fontWeight: 300 }}>{value}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Onboarding 3 — single illustrated card
// ─────────────────────────────────────────────────────────────
function ScreenOnboarding3v2() {
  return (
    <MPhone mood="dawn">
      <div style={{ position:'absolute', inset:0, padding:'120px 28px 0' }}>
        <div className="serif" style={{ fontSize: 38, color: M.ink, lineHeight: 1.05, letterSpacing: -0.8, padding:'0 8px', fontWeight: 200 }}>
          Quietly,<br/>with your permission.
        </div>
        <div style={{ marginTop: 14, fontSize: 14.5, color: M.ink2, padding:'0 8px', lineHeight: 1.55, maxWidth: 300 }}>
          One nudge a day. Sessions saved to Health. Both optional, both reversible.
        </div>

        {/* Single illustrated card */}
        <MGlass radius={28} tint={0.65} style={{ marginTop: 36 }}>
          <div style={{ position:'relative', zIndex:1, padding: 24 }}>
            {/* Illustration: a soft heart pulse + bell shimmer */}
            <div style={{ height: 120, position:'relative', display:'flex', alignItems:'center', justifyContent:'center', marginBottom: 18 }}>
              <MAura size={180} hue={M.aura} style={{ top: '50%', left: '50%', transform:'translate(-50%,-50%)' }}/>
              <svg width="200" height="100" viewBox="0 0 200 100" style={{ position:'relative' }}>
                {/* heart pulse line */}
                <path d="M0 50 L40 50 L48 35 L56 65 L64 25 L72 75 L80 50 L120 50 L128 38 L138 62 L148 50 L200 50"
                  stroke={M.accent} strokeWidth="1.4" fill="none" strokeLinecap="round" strokeLinejoin="round" opacity="0.7"/>
                {/* bell shimmer rings around right anchor */}
                <circle cx="155" cy="50" r="6" fill={M.warm}/>
                <circle cx="155" cy="50" r="14" stroke={M.warm} strokeWidth="0.8" fill="none" opacity="0.45"/>
                <circle cx="155" cy="50" r="22" stroke={M.warm} strokeWidth="0.6" fill="none" opacity="0.25"/>
                <circle cx="155" cy="50" r="30" stroke={M.warm} strokeWidth="0.5" fill="none" opacity="0.12"/>
                {/* heart anchor on left */}
                <path d="M40 47 a4 4 0 0 1 8 0 a4 4 0 0 1 8 0 c0 4 -8 9 -8 9 c0 0 -8 -5 -8 -9z" fill={M.accent} opacity="0.85"/>
              </svg>
            </div>

            <div style={{ display:'flex', flexDirection:'column', gap: 14 }}>
              <PermRow
                label="Mindful Minutes"
                sub="Sessions count toward your day in Apple Health."
                color={M.accent}
              />
              <div style={{ height: 0.5, background: M.hairline }}/>
              <PermRow
                label="Gentle reminders"
                sub="One soft notification, at your chosen hour."
                color={M.warm}
              />
            </div>
          </div>
        </MGlass>
      </div>

      <div style={{ position:'absolute', bottom: 130, left:0, right:0, display:'flex', gap: 6, justifyContent:'center' }}>
        <Dot/><Dot/><Dot active/>
      </div>
      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24, display:'flex', flexDirection:'column', gap: 10, alignItems:'center' }}>
        <MPrimaryButton icon="arrow">Allow & begin</MPrimaryButton>
        <div style={{ fontSize: 13.5, color: M.ink2, fontWeight: 500 }}>Skip for now</div>
      </div>
    </MPhone>
  );
}

function PermRow({ label, sub, color }) {
  return (
    <div style={{ display:'flex', alignItems:'flex-start', gap: 12 }}>
      <div style={{ marginTop: 6, width: 8, height: 8, borderRadius:'50%', background: color, flexShrink: 0 }}/>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, color: M.ink, fontWeight: 500 }}>{label}</div>
        <div style={{ marginTop: 2, fontSize: 12.5, color: M.ink2, lineHeight: 1.5 }}>{sub}</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Audio + Haptic language style page
// ─────────────────────────────────────────────────────────────
function ScreenAudioHaptic() {
  return (
    <div style={{ width: 920, padding: 40, background: M.bg, borderRadius: 24, position:'relative', overflow:'hidden', boxShadow:'0 40px 80px rgba(15,27,45,0.18)' }}>
      <MBackdrop mood="day"/>
      <div style={{ position:'relative' }}>
        <div className="serif" style={{ fontSize: 44, fontWeight: 200, letterSpacing: -1 }}>Sound &amp; touch</div>
        <div style={{ marginTop: 6, fontSize: 15, color: M.ink2 }}>How Medity sounds in the ear and feels in the hand.</div>

        {/* Bell waveforms */}
        <div style={{ marginTop: 36 }}>
          <SecHead n="01" title="Bells"/>
          <div style={{ marginTop: 16, display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap: 14 }}>
            <BellCard name="Tibetan bowl" sub="Resonant · 8s decay" envelope={[0.0,1.0,0.85,0.65,0.50,0.40,0.30,0.22,0.15,0.10,0.06,0.03,0.01]}/>
            <BellCard name="Japanese bell" sub="Bright · 5s decay" envelope={[0.0,1.0,0.62,0.40,0.25,0.15,0.08,0.04,0.02,0.01]}/>
            <BellCard name="Soft chime" sub="Near · 2.5s decay" envelope={[0.0,0.85,0.50,0.28,0.15,0.07,0.03,0.01]}/>
          </div>
        </div>

        {/* Volume duck curve */}
        <div style={{ marginTop: 36 }}>
          <SecHead n="02" title="Ducking"/>
          <div style={{ marginTop: 16, padding: 22, borderRadius: 18, border:`0.5px dashed ${M.hairline2}`, background:'rgba(255,255,255,0.4)' }}>
            <div style={{ fontSize: 12, color: M.ink2, lineHeight: 1.55, marginBottom: 14, maxWidth: 600 }}>
              When a bell rings during a session, the background sound dips by ~6&nbsp;dB over 600&nbsp;ms, holds while the bell sustains, then returns over 1.2&nbsp;s. The bell never competes with the sound — it sits inside it.
            </div>
            <DuckCurve/>
          </div>
        </div>

        {/* Haptics */}
        <div style={{ marginTop: 36 }}>
          <SecHead n="03" title="Haptics"/>
          <div style={{ marginTop: 16, display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap: 14 }}>
            <HapticCard name="Begin" sub="Soft tap, then breath" pattern={[{ t: 0, k: 'soft' },{ t: 1.5, k: 'breath' }]}/>
            <HapticCard name="Bell interval" sub="Two whisper taps" pattern={[{ t: 0.2, k: 'whisper' },{ t: 0.6, k: 'whisper' }]}/>
            <HapticCard name="Complete" sub="Three soft pulses" pattern={[{ t: 0, k: 'soft' },{ t: 0.5, k: 'soft' },{ t: 1.0, k: 'soft' }]}/>
          </div>
        </div>
      </div>
    </div>
  );
}

function BellCard({ name, sub, envelope }) {
  // draw envelope as a decaying sine wave
  const W = 240, H = 70;
  const dur = envelope.length;
  const cycles = 14;
  const samples = 240;
  const path = Array.from({length: samples}).map((_, i) => {
    const t = (i / samples) * (dur - 1);
    const lo = Math.floor(t), hi = Math.min(dur - 1, lo + 1);
    const env = envelope[lo] + (envelope[hi] - envelope[lo]) * (t - lo);
    const sin = Math.sin((i / samples) * cycles * 2 * Math.PI);
    const y = H/2 - sin * env * (H/2 - 4);
    return `${i === 0 ? 'M' : 'L'} ${(i / samples) * W} ${y}`;
  }).join(' ');
  return (
    <div style={{ padding: 18, borderRadius: 18, border:`0.5px solid ${M.hairline}`, background:'rgba(255,255,255,0.5)' }}>
      <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
        <div style={{ fontSize: 14, color: M.ink, fontWeight: 500 }}>{name}</div>
        <div style={{ fontSize: 10.5, color: M.ink3, fontFamily:'ui-monospace, "SF Mono", monospace' }}>{sub}</div>
      </div>
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} style={{ marginTop: 10 }}>
        <line x1="0" y1={H/2} x2={W} y2={H/2} stroke={M.hairline2} strokeWidth="0.5"/>
        <path d={path} stroke={M.accent} strokeWidth="1.1" fill="none"/>
      </svg>
    </div>
  );
}

function DuckCurve() {
  const W = 800, H = 100;
  // 0-100% volume; dip from 100 -> 60 around bell, back to 100
  const points = Array.from({length: 200}).map((_, i) => {
    const t = i / 200;
    let v = 1.0;
    if (t > 0.20 && t < 0.30) v = 1.0 - ((t - 0.20) / 0.10) * 0.4;
    else if (t >= 0.30 && t < 0.55) v = 0.6;
    else if (t >= 0.55 && t < 0.75) v = 0.6 + ((t - 0.55) / 0.20) * 0.4;
    return v;
  });
  const path = points.map((v, i) => `${i === 0 ? 'M' : 'L'} ${(i/200) * W} ${H - v * (H - 12) - 6}`).join(' ');
  return (
    <svg width="100%" height={H + 30} viewBox={`0 0 ${W} ${H + 30}`}>
      <line x1="0" y1={H - 6} x2={W} y2={H - 6} stroke={M.hairline2} strokeWidth="0.5"/>
      <path d={path} stroke={M.accent} strokeWidth="1.6" fill="none"/>
      {/* bell event marker */}
      <line x1={W * 0.32} y1="0" x2={W * 0.32} y2={H - 6} stroke={M.warm} strokeWidth="0.8" strokeDasharray="3 3"/>
      <circle cx={W * 0.32} cy="14" r="4" fill={M.warm}/>
      <text x={W * 0.32 + 10} y="18" fontSize="11" fill={M.warm} fontFamily={M.sans}>bell</text>
      {/* labels */}
      <text x="0" y={H + 22} fontSize="10" fill={M.ink3} fontFamily={M.sans} letterSpacing="1.5">0s</text>
      <text x={W - 30} y={H + 22} fontSize="10" fill={M.ink3} fontFamily={M.sans} letterSpacing="1.5">3s</text>
      <text x="6" y="18" fontSize="10" fill={M.ink3} fontFamily={M.sans}>100%</text>
      <text x="6" y={H - 6 - (H - 12) * 0.6 + 4} fontSize="10" fill={M.ink3} fontFamily={M.sans}>60%</text>
    </svg>
  );
}

function HapticCard({ name, sub, pattern }) {
  // Visualize as a small ring with dots at times
  const W = 240, H = 70;
  const dur = 1.6;
  return (
    <div style={{ padding: 18, borderRadius: 18, border:`0.5px solid ${M.hairline}`, background:'rgba(255,255,255,0.5)' }}>
      <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
        <div style={{ fontSize: 14, color: M.ink, fontWeight: 500 }}>{name}</div>
        <div style={{ fontSize: 10.5, color: M.ink3 }}>{sub}</div>
      </div>
      <svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} style={{ marginTop: 10 }}>
        <line x1="0" y1={H/2} x2={W} y2={H/2} stroke={M.hairline2} strokeWidth="0.5"/>
        {pattern.map((p, i) => {
          const x = (p.t / dur) * W;
          const r = p.k === 'breath' ? 14 : p.k === 'soft' ? 8 : 5;
          const opa = p.k === 'whisper' ? 0.4 : 0.7;
          return (
            <g key={i}>
              <circle cx={x} cy={H/2} r={r * 1.6} fill={M.warm} opacity={opa * 0.15}/>
              <circle cx={x} cy={H/2} r={r} fill={M.warm} opacity={opa}/>
            </g>
          );
        })}
      </svg>
    </div>
  );
}

Object.assign(window, {
  ScreenStatsEmpty, ScreenAchievementDetail, ScreenOnboarding3v2, ScreenAudioHaptic,
  BellCard, DuckCurve, HapticCard, DetailStat, PermRow,
});
