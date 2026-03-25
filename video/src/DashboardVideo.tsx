import {AbsoluteFill, Audio, useCurrentFrame, interpolate, Sequence, staticFile} from 'remotion';
import {TitleScene} from './components/TitleScene';
import {FeaturesScene} from './components/FeaturesScene';
import {AgentsScene} from './components/AgentsScene';
import {ClosingScene} from './components/ClosingScene';

// Audio timing (from voiceover.vtt):
// 0.1-2.3s  "Too many projects."
// 2.2-4.0s  "No overview."
// 4.0-6.8s  "Project Dashboard changes that."
// 6.8-14.0s "One single HTML file — sortable tables, project cards, docs inventory, synergy maps."
// 14.0-20.9s "And three AI agents — Cockpit, Radar, and Bridge — keep everything updated automatically."
// 20.9-22.4s "Clone it."
// 22.4-24.2s "Run Claude."
// 24.2-27.0s "Say: set up for my projects."
// 27.0-29.2s "Zero dependencies."
// 29.2-31.4s "Fully AI-native."
// 31.4-33.8s "Fork it and make it yours."

export const DashboardVideo: React.FC = () => {
	const frame = useCurrentFrame();

	const bgHue = interpolate(frame, [0, 1050], [220, 260], {
		extrapolateLeft: 'clamp',
		extrapolateRight: 'clamp',
	});

	return (
		<AbsoluteFill>
			{/* Voiceover */}
			<Audio src={staticFile('voiceover.mp3')} volume={1} />

			{/* Animated background */}
			<AbsoluteFill
				style={{
					background: `linear-gradient(135deg, hsl(${bgHue}, 30%, 8%) 0%, hsl(${bgHue + 20}, 40%, 12%) 100%)`,
				}}
			/>

			{/* Scene 1: Title + Problem (0-6.8s = 0-204 frames) */}
			{/* "Too many projects. No overview. Project Dashboard changes that." */}
			<Sequence from={0} durationInFrames={220}>
				<TitleScene />
			</Sequence>

			{/* Scene 2: Features (5.5-14.5s = 165-435 frames) */}
			{/* "One single HTML file — sortable tables, project cards, docs inventory, synergy maps." */}
			<Sequence from={165} durationInFrames={270}>
				<FeaturesScene />
			</Sequence>

			{/* Scene 3: AI Agents (13.5-21.5s = 405-645 frames) */}
			{/* "And three AI agents — Cockpit, Radar, and Bridge — keep everything updated automatically." */}
			<Sequence from={405} durationInFrames={240}>
				<AgentsScene />
			</Sequence>

			{/* Scene 4: Closing (20.5-35s = 615-1050 frames) */}
			{/* "Clone it. Run Claude. Say: set up for my projects. Zero dependencies. Fully AI-native. Fork it and make it yours." */}
			<Sequence from={615} durationInFrames={435}>
				<ClosingScene />
			</Sequence>
		</AbsoluteFill>
	);
};
