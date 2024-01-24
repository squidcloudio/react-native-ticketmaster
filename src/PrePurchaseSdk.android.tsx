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

interface PrePurchaseViewManager extends ViewProps {
  textProps: {
    attractionId: string;
  };
}
const PrePurchaseViewManager = requireNativeComponent<PrePurchaseViewManager>(
  'PrePurchaseViewManager',
);

const createFragment = (viewId: number | null) =>
  UIManager.dispatchViewManagerCommand(
    viewId,
    (UIManager as any).PrePurchaseViewManager.Commands.create.toString(),
    [viewId],
  );

export const PrePurchaseSdk = ({ attractionId }: { attractionId: string }) => {
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
    attractionId,
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
      {mounted && <PrePurchaseViewManager textProps={textProps} ref={ref} />}
    </View>
  );
};
