import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

const folders = [
	{name: 'design-system-a/', color: '#e8432a', x: 200},
	{name: 'design-system-b/', color: '#005b8e', x: 500},
	{name: 'component-lib/', color: '#7c3aed', x: 800},
	{name: 'marketing-site/', color: '#10b981', x: 1100},
	{name: 'mobile-app/', color: '#f59e0b', x: 1400},
];

export const ProblemScene: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps} = useVideoConfig();

	const fadeIn = interpolate(frame, [0, 30], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});
	const fadeOut = interpolate(frame, [150, 180], [1, 0], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	const questionOpacity = interpolate(frame, [60, 90], [0, 1], {
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
				opacity: fadeIn * fadeOut,
			}}
		>
			{/* Scattered folders */}
			<div style={{position: 'relative', width: 1600, height: 300}}>
				{folders.map((folder, i) => {
					const s = spring({fps, frame: frame - i * 8, config: {damping: 200}});
					return (
						<div
							key={folder.name}
							style={{
								position: 'absolute',
								left: folder.x - 100,
								top: 80,
								transform: `scale(${s})`,
								display: 'flex',
								flexDirection: 'column',
								alignItems: 'center',
							}}
						>
							<div
								style={{
									width: 80,
									height: 60,
									borderRadius: 8,
									background: folder.color,
									opacity: 0.8,
								}}
							/>
							<span
								style={{
									color: '#8a90a8',
									fontSize: 20,
									marginTop: 8,
									fontFamily: 'monospace',
								}}
							>
								{folder.name}
							</span>
						</div>
					);
				})}
			</div>

			{/* Question */}
			<div
				style={{
					fontSize: 48,
					color: 'white',
					opacity: questionOpacity,
					fontFamily: 'system-ui, sans-serif',
					textAlign: 'center',
					marginTop: 40,
				}}
			>
				Too many projects. No overview.
			</div>

			<div
				style={{
					fontSize: 28,
					color: '#8a90a8',
					opacity: questionOpacity,
					fontFamily: 'system-ui, sans-serif',
					textAlign: 'center',
					marginTop: 16,
				}}
			>
				What changed? Where are synergies? Which docs are stale?
			</div>
		</AbsoluteFill>
	);
};
