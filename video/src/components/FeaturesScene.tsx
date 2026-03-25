import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

// This scene covers: "One single HTML file — sortable tables, project cards, docs inventory, synergy maps."
// Duration: 270 frames (~9s), starts at ~5.5s in audio

const features = [
	{icon: '\u{1F4CA}', title: 'Sortable Table', desc: 'Metrics, phases, tech stacks', delay: 0},
	{icon: '\u{1F4C4}', title: 'Project Cards', desc: 'Details & docs per project', delay: 30},
	{icon: '\u{1F4DA}', title: 'Docs Inventory', desc: '4 types, sizes, timestamps', delay: 60},
	{icon: '\u{1F517}', title: 'Synergy Map', desc: 'Cross-project connections', delay: 90},
];

export const FeaturesScene: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps} = useVideoConfig();

	const headerOpacity = interpolate(frame, [0, 25], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	const singleFileOpacity = interpolate(frame, [10, 35], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	const fadeOut = interpolate(frame, [235, 270], [1, 0], {
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
				padding: 80,
			}}
		>
			{/* "One single HTML file" */}
			<div
				style={{
					fontSize: 52,
					fontWeight: 700,
					color: 'white',
					opacity: headerOpacity,
					fontFamily: 'system-ui, sans-serif',
					marginBottom: 16,
				}}
			>
				One single HTML file
			</div>

			{/* Code badge */}
			<div
				style={{
					padding: '8px 24px',
					borderRadius: 8,
					background: 'rgba(16,185,129,0.15)',
					border: '1px solid rgba(16,185,129,0.3)',
					fontFamily: 'monospace',
					fontSize: 24,
					color: '#10b981',
					opacity: singleFileOpacity,
					marginBottom: 50,
				}}
			>
				index.html — no build, no framework, no dependencies
			</div>

			{/* Feature cards — each appears as its name is spoken */}
			<div
				style={{
					display: 'flex',
					gap: 36,
					flexWrap: 'wrap',
					justifyContent: 'center',
				}}
			>
				{features.map((feat) => {
					const cardSpring = spring({
						fps,
						frame: frame - 40 - feat.delay,
						config: {damping: 200},
					});
					const cardOpacity = interpolate(frame, [40 + feat.delay, 55 + feat.delay], [0, 1], {
						extrapolateLeft: 'clamp',
						extrapolateRight: 'clamp',
					});
					return (
						<div
							key={feat.title}
							style={{
								width: 360,
								padding: 28,
								borderRadius: 16,
								background: 'rgba(255,255,255,0.05)',
								border: '1px solid rgba(255,255,255,0.1)',
								transform: `scale(${cardSpring}) translateY(${(1 - cardSpring) * 20}px)`,
								opacity: cardOpacity,
								display: 'flex',
								flexDirection: 'column',
								gap: 10,
							}}
						>
							<span style={{fontSize: 36}}>{feat.icon}</span>
							<span
								style={{
									fontSize: 24,
									fontWeight: 600,
									color: 'white',
									fontFamily: 'system-ui, sans-serif',
								}}
							>
								{feat.title}
							</span>
							<span
								style={{
									fontSize: 18,
									color: '#8a90a8',
									fontFamily: 'system-ui, sans-serif',
								}}
							>
								{feat.desc}
							</span>
						</div>
					);
				})}
			</div>
		</AbsoluteFill>
	);
};
