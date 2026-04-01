import cn from '@/core/utils/cn';
import { AnimatePresence, motion, type HTMLMotionProps } from 'motion/react';

interface Props extends HTMLMotionProps<'div'> {
  direction: 1 | -1;
  current: number;
  extended?: number;
}

export default function Slide({
  direction,
  current,
  extended = 200,
  className,
  ...props
}: Props) {
  return (
    <AnimatePresence initial={false} custom={direction} mode="wait">
      <motion.div
        className={cn('flex justify-center w-full', className)}
        key={current}
        custom={direction}
        variants={{
          enter: (direction: 1 | -1) => ({
            x: direction === 1 ? extended : -extended,
            opacity: 0,
          }),
          center: {
            x: 0,
            opacity: 1,
          },
          exit: (direction: 1 | -1) => ({
            x: direction === 1 ? -extended : extended,
            opacity: 0,
          }),
        }}
        initial="enter"
        animate="center"
        exit="exit"
        transition={{
          duration: 0.2,
        }}
        {...props}
      />
    </AnimatePresence>
  );
}
