import {AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate, spring} from 'remotion';

// This scene covers: "Too many projects. No overview. Project Dashboard changes that."
// Duration: 220 frames (~7.3s)

const folders = [
	{name: 'project-a/', color: '#e8432a', x: 250},
	{name: 'project-b/', color: '#005b8e', x: 530},
	{name: 'project-c/', color: '#7c3aed', x: 810},
	{name: 'project-d/', color: '#10b981', x: 1090},
	{name: 'project-e/', color: '#f59e0b', x: 1370},
];

export const TitleScene: React.FC = () => {
	const frame = useCurrentFrame();
	const {fps} = useVideoConfig();

	// Phase 1 (0-60): Scattered folders appear — "Too many projects."
	const foldersOpacity = interpolate(frame, [0, 15], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// Phase 2 (60-120): "No overview." — folders shake/scatter
	const chaos = frame > 60 && frame < 120 ? Math.sin(frame * 0.5) * 3 : 0;

	// Phase 3 (120-200): "Project Dashboard changes that." — folders converge, title appears
	const titleScale = spring({fps, frame: frame - 120, config: {damping: 200}});
	const titleOpacity = interpolate(frame, [120, 140], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	const subtitleOpacity = interpolate(frame, [145, 165], [0, 1], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// Fade out at end
	const fadeOut = interpolate(frame, [190, 220], [1, 0], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	// Folders converge toward center after frame 120
	const converge = interpolate(frame, [120, 160], [0, 1], {
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
			{/* Scattered folders */}
			<div style={{position: 'relative', width: 1600, height: 200, opacity: foldersOpacity}}>
				{folders.map((folder, i) => {
					const s = spring({fps, frame: frame - i * 6, config: {damping: 200}});
					const targetX = 960 - 50;
					const currentX = folder.x - 50 + (targetX - (folder.x - 50)) * converge;
					const scale = 1 - converge * 0.6;
					return (
						<div
							key={folder.name}
							style={{
								position: 'absolute',
								left: currentX,
								top: 60 + chaos * (i % 2 === 0 ? 1 : -1),
								transform: `scale(${s * scale})`,
								opacity: 1 - converge * 0.8,
								display: 'flex',
								flexDirection: 'column',
								alignItems: 'center',
							}}
						>
							<div
								style={{
									width: 70,
									height: 52,
									borderRadius: 8,
									background: folder.color,
									opacity: 0.8,
								}}
							/>
							<span
								style={{
									color: '#8a90a8',
									fontSize: 18,
									marginTop: 6,
									fontFamily: 'monospace',
								}}
							>
								{folder.name}
							</span>
						</div>
					);
				})}
			</div>

			{/* "Too many projects. No overview." */}
			<div
				style={{
					fontSize: 44,
					color: '#8a90a8',
					fontFamily: 'system-ui, sans-serif',
					textAlign: 'center',
					marginTop: 20,
					opacity: foldersOpacity * (1 - titleOpacity),
				}}
			>
				Too many projects. No overview.
			</div>

			{/* Title: "Project Dashboard changes that." */}
			<div
				style={{
					position: 'absolute',
					top: '50%',
					left: '50%',
					transform: `translate(-50%, -50%) scale(${titleScale})`,
					opacity: titleOpacity,
					display: 'flex',
					flexDirection: 'column',
					alignItems: 'center',
					gap: 16,
				}}
			>
				<div
					style={{
						width: 100,
						height: 100,
						borderRadius: 20,
						background: '#888',
						display: 'flex',
						alignItems: 'center',
						justifyContent: 'center',
						marginBottom: 20,
					}}
				>
					<span style={{fontSize: 46, fontWeight: 700, color: 'white', fontFamily: 'system-ui'}}>
						PD
					</span>
				</div>
				<div style={{fontSize: 80, fontWeight: 700, color: 'white', fontFamily: 'system-ui', textAlign: 'center'}}>
					Project Dashboard
				</div>
				<div style={{fontSize: 32, color: '#8a90a8', fontFamily: 'system-ui', opacity: subtitleOpacity}}>
					One file. All your projects. AI-powered.
				</div>
			</div>
		</AbsoluteFill>
	);
};
