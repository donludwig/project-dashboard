import {Composition} from 'remotion';
import {DashboardVideo} from './DashboardVideo';

export const Root: React.FC = () => {
	return (
		<>
			<Composition
				id="MyComp"
				component={DashboardVideo}
				durationInFrames={1050}
				width={1920}
				height={1080}
				fps={30}
				defaultProps={{}}
			/>
		</>
	);
};
