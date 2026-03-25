import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

// This scene covers: "And three AI agents — Cockpit, Radar, and Bridge — keep everything updated automatically."
// Duration: 240 frames (~8s), starts at ~13.5s in audio

const agents = [
	{name: 'Cockpit', icon: '\u2699', role: 'Coordinator', color: '#3b82f6', delay: 25},
	{name: 'Radar', icon: '\u{1F4E1}', role: 'Scanner', color: '#10b981', delay: 45},
	{name: 'Bridge', icon: '\u{1F309}', role: 'Synergy Finder', color: '#f59e0b', delay: 65},
];

export const AgentsScene: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps} = useVideoConfig();

	const titleOpacity = interpolate(frame, [0, 25], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});
	const fadeOut = interpolate(frame, [205, 240], [1, 0], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// Connection lines appear after all agents
	const lineOpacity = interpolate(frame, [90, 110], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// "keep everything updated automatically" text
	const autoOpacity = interpolate(frame, [110, 135], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// Command prompt
	const cmdOpacity = interpolate(frame, [145, 165], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	return (
		<AbsoluteFill
			style={{
				display: 'flex',
				flexDirection: 'column',
				alignItems: 'center',
				justifyContent: 'center',
				opacity: fadeOut,
			}}
		>
			<div
				style={{
					fontSize: 52,
					fontWeight: 700,
					color: 'white',
					opacity: titleOpacity,
					fontFamily: 'system-ui, sans-serif',
					marginBottom: 50,
				}}
			>
				Three AI Agents
			</div>

			{/* Agent cards — each appears as its name is spoken */}
			<div style={{display: 'flex', gap: 60, alignItems: 'flex-start'}}>
				{agents.map((agent) => {
					const s = spring({fps, frame: frame - agent.delay, config: {damping: 200}});
					return (
						<div
							key={agent.name}
							style={{
								display: 'flex',
								flexDirection: 'column',
								alignItems: 'center',
								transform: `scale(${s})`,
								width: 200,
							}}
						>
							<div
								style={{
									width: 110,
									height: 110,
									borderRadius: 22,
									background: agent.color,
									display: 'flex',
									alignItems: 'center',
									justifyContent: 'center',
									fontSize: 44,
								}}
							>
								{agent.icon}
							</div>
							<span
								style={{
									fontSize: 30,
									fontWeight: 600,
									color: 'white',
									marginTop: 14,
									fontFamily: 'system-ui, sans-serif',
								}}
							>
								{agent.name}
							</span>
							<span
								style={{
									fontSize: 20,
									color: agent.color,
									fontFamily: 'system-ui, sans-serif',
								}}
							>
								{agent.role}
							</span>
						</div>
					);
				})}
			</div>

			{/* Connection arrows */}
			<svg width="700" height="30" style={{marginTop: 24, opacity: lineOpacity}}>
				<defs>
					<marker id="arrow" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
						<polygon points="0 0, 8 3, 0 6" fill="#3b82f6" />
					</marker>
				</defs>
				<line x1="120" y1="15" x2="280" y2="15" stroke="#3b82f6" strokeWidth="2" markerEnd="url(#arrow)" />
				<line x1="420" y1="15" x2="580" y2="15" stroke="#3b82f6" strokeWidth="2" markerEnd="url(#arrow)" />
			</svg>

			{/* Auto-update tagline */}
			<div
				style={{
					fontSize: 28,
					color: '#8a90a8',
					opacity: autoOpacity,
					fontFamily: 'system-ui, sans-serif',
					marginTop: 28,
				}}
			>
				Keep everything updated automatically
			</div>

			{/* Command example */}
			<div
				style={{
					marginTop: 28,
					padding: '14px 36px',
					borderRadius: 12,
					background: 'rgba(255,255,255,0.05)',
					border: '1px solid rgba(255,255,255,0.15)',
					fontFamily: 'monospace',
					fontSize: 26,
					color: '#10b981',
					opacity: cmdOpacity,
				}}
			>
				$ claude --agent cockpit
			</div>
		</AbsoluteFill>
	);
};
