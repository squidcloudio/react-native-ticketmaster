import { useEffect, useRef, useState } from 'react';
import {
  LayoutChangeEvent,
  PixelRatio,
  UIManager,
  View,
  ViewProps,
  findNodeHandle,
  requireNativeComponent,
} from 'react-native';

interface PurchaseViewManagerProps extends ViewProps {
  textProps: {
    eventId: string;
    width: number;
    height: number;
  };
}

const PurchaseViewManager = requireNativeComponent<PurchaseViewManagerProps>(
  'PurchaseViewManager',
);

const createFragment = (viewId: number | null) =>
  UIManager.dispatchViewManagerCommand(
    viewId,
    (UIManager as any).PurchaseViewManager.Commands.create.toString(),
    [viewId],
  );

export const PurchaseSdk = ({ eventId }: { eventId: string }) => {
  const ref = useRef(null);
  const [mounted, setMounted] = useState(false);
  const [layout, setLayout] = useState({ width: 0, height: 0 });

  const onLayout = (event: LayoutChangeEvent) => {
    const { width, height } = event.nativeEvent.layout;
    setLayout({
      // converts dpi to px, provide desired height
      width: PixelRatio.getPixelSizeForLayoutSize(width),
      height: PixelRatio.getPixelSizeForLayoutSize(height),
    });
    setMounted(true);
  };

  const textProps = {
    eventId,
    ...layout,
  };

  useEffect(() => {
    if (!mounted) return;
    const viewId = findNodeHandle(ref.current);
    if (viewId) {
      createFragment(viewId);
    }
  }, [mounted]);

  return (
    <View onLayout={onLayout} style={{ flex: 1 }}>
      {mounted && <PurchaseViewManager textProps={textProps} ref={ref} />}
    </View>
  );
};
