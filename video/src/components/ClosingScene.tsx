import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

// This scene covers:
// 20.9-22.4s "Clone it."
// 22.4-24.2s "Run Claude."
// 24.2-27.0s "Say: set up for my projects."
// 27.0-29.2s "Zero dependencies."
// 29.2-31.4s "Fully AI-native."
// 31.4-33.8s "Fork it and make it yours."
// Duration: 435 frames (~14.5s), starts at ~20.5s

const steps = [
	{text: '$ git clone', mono: true, delay: 10},
	{text: '$ claude', mono: true, delay: 55},
	{text: '"Set up for my projects"', mono: false, delay: 110},
];

const badges = [
	{text: 'Zero Dependencies', delay: 195},
	{text: 'AI-Native', delay: 255},
];

export const ClosingScene: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps} = useVideoConfig();

	const fadeIn = interpolate(frame, [0, 20], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// "Fork it and make it yours."
	const ctaOpacity = interpolate(frame, [310, 340], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});
	const ctaScale = spring({fps, frame: frame - 310, config: {damping: 200}});

	// GitHub URL
	const urlOpacity = interpolate(frame, [350, 375], [0, 1], {
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
				opacity: fadeIn,
			}}
		>
			{/* PD Icon */}
			<div
				style={{
					width: 80,
					height: 80,
					borderRadius: 16,
					background: '#888',
					display: 'flex',
					alignItems: 'center',
					justifyContent: 'center',
					marginBottom: 40,
				}}
			>
				<span style={{fontSize: 36, fontWeight: 700, color: 'white', fontFamily: 'system-ui'}}>PD</span>
			</div>

			{/* Three steps — appear one by one synced with speech */}
			<div style={{display: 'flex', gap: 30, marginBottom: 40}}>
				{steps.map((step) => {
					const s = spring({fps, frame: frame - step.delay, config: {damping: 200}});
					const opacity = interpolate(frame, [step.delay, step.delay + 15], [0, 1], {
						extrapolateLeft: 'clamp',
						extrapolateRight: 'clamp',
					});
					return (
						<div
							key={step.text}
							style={{
								padding: '14px 30px',
								borderRadius: 12,
								background: 'rgba(255,255,255,0.05)',
								border: '1px solid rgba(255,255,255,0.15)',
								fontFamily: step.mono ? 'monospace' : 'system-ui, sans-serif',
								fontSize: 28,
								color: step.mono ? '#10b981' : '#e0e4ef',
								transform: `scale(${s})`,
								opacity,
							}}
						>
							{step.text}
						</div>
					);
				})}
			</div>

			{/* Badges — "Zero dependencies. Fully AI-native." */}
			<div style={{display: 'flex', gap: 24, marginBottom: 50}}>
				{badges.map((badge) => {
					const opacity = interpolate(frame, [badge.delay, badge.delay + 20], [0, 1], {
						extrapolateLeft: 'clamp',
						extrapolateRight: 'clamp',
					});
					return (
						<div
							key={badge.text}
							style={{
								padding: '10px 24px',
								borderRadius: 20,
								background: 'rgba(59,130,246,0.1)',
								border: '1px solid rgba(59,130,246,0.3)',
								fontSize: 22,
								color: '#3b82f6',
								fontFamily: 'system-ui, sans-serif',
								fontWeight: 500,
								opacity,
							}}
						>
							{badge.text}
						</div>
					);
				})}
			</div>

			{/* "Fork it and make it yours." */}
			<div
				style={{
					fontSize: 60,
					fontWeight: 700,
					color: 'white',
					fontFamily: 'system-ui, sans-serif',
					textAlign: 'center',
					opacity: ctaOpacity,
					transform: `scale(${ctaScale})`,
					marginBottom: 24,
				}}
			>
				Fork it. Make it yours.
			</div>

			{/* GitHub URL */}
			<div
				style={{
					fontSize: 26,
					color: '#3b82f6',
					opacity: urlOpacity,
					fontFamily: 'monospace',
				}}
			>
				github.com/donludwig/project-dashboard
			</div>
		</AbsoluteFill>
	);
};
