import { useContext } from 'react';
import { TicketmasterContext } from './TicketmasterProvider';

export const useTicketmaster = () => {
  return useContext(TicketmasterContext);
};
